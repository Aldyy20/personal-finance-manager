<?php

namespace App\Services;

use App\Exceptions\FinancialValidationException;
use App\Exceptions\OwnershipViolationException;
use App\Models\Receipt;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Throwable;

/**
 * Handles private receipt image storage, signature/MIME validation, checksum verification, and OCR metadata.
 */
class ReceiptService
{
    public const MAX_FILE_SIZE_BYTES = 5242880; // 5 MB

    /**
     * @var array<string, string>
     */
    private const ALLOWED_MIMES = [
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
    ];

    public function __construct(
        private readonly LedgerService $ledgerService,
        private readonly UserBootstrapService $syncRecorder,
    ) {}

    /**
     * Validates and stores an uploaded receipt privately outside the web public directory.
     *
     * @param  array<string, mixed>  $data
     */
    public function uploadReceipt(User $user, UploadedFile $file, array $data): Receipt
    {
        $transactionId = (string) ($data['transaction_id'] ?? '');
        $transaction = Transaction::query()->find($transactionId);

        if ($transaction === null) {
            throw new FinancialValidationException(
                'Transaction not found.',
                ['transaction_id' => ['Transaction does not exist.']]
            );
        }

        if ($transaction->user_id !== $user->id) {
            throw new OwnershipViolationException('You do not own this transaction.');
        }

        $fileSize = (int) ($file->getSize() ?: 0);
        if ($fileSize <= 0 || $fileSize > self::MAX_FILE_SIZE_BYTES) {
            throw new FinancialValidationException(
                'Receipt file size must not exceed 5 MB.',
                ['file' => ['File size must be between 1 byte and 5 MB.']]
            );
        }

        // Validate actual file signature MIME using finfo
        $detectedMime = (string) $file->getMimeType();
        if (! array_key_exists($detectedMime, self::ALLOWED_MIMES)) {
            throw new FinancialValidationException(
                'Invalid receipt file type. Only JPEG, PNG, and WEBP images are allowed.',
                ['file' => ["Unsupported MIME type: {$detectedMime}."]]
            );
        }

        $realPath = $file->getRealPath();
        $actualChecksum = $realPath !== false ? hash_file('sha256', $realPath) : null;
        if ($actualChecksum === false || $actualChecksum === null) {
            throw new FinancialValidationException('Unable to compute file checksum.');
        }

        if (! empty($data['checksum']) && strtolower((string) $data['checksum']) !== strtolower($actualChecksum)) {
            throw new FinancialValidationException(
                'File checksum mismatch.',
                ['checksum' => ['Uploaded file checksum does not match expected value.']]
            );
        }

        $receiptId = (string) ($data['id'] ?? Str::uuid());
        $extension = self::ALLOWED_MIMES[$detectedMime];
        $directory = "receipts/{$user->id}";
        $fileName = "{$receiptId}.{$extension}";
        $storedPath = Storage::disk('local')->putFileAs($directory, $file, $fileName);

        if ($storedPath === false) {
            throw new FinancialValidationException('Failed to store receipt file.');
        }

        $extractedData = $data['extracted_data'] ?? null;
        if (is_string($extractedData)) {
            $decoded = json_decode($extractedData, true);
            $extractedData = is_array($decoded) ? $decoded : null;
        }

        try {
            return $this->ledgerService->executeAtomically(function () use (
                $user,
                $receiptId,
                $transaction,
                $storedPath,
                $file,
                $detectedMime,
                $fileSize,
                $actualChecksum,
                $data,
                $extractedData
            ) {
                $receipt = Receipt::query()->create([
                    'id' => $receiptId,
                    'transaction_id' => $transaction->id,
                    'user_id' => $user->id,
                    'file_path' => $storedPath,
                    'file_name' => $file->getClientOriginalName(),
                    'mime_type' => $detectedMime,
                    'file_size' => $fileSize,
                    'checksum' => $actualChecksum,
                    'ocr_text' => $data['ocr_text'] ?? null,
                    'extracted_data' => $extractedData,
                    'version' => 1,
                ]);

                $this->syncRecorder->recordSyncChange($user->id, 'receipts', $receipt->id, 'create', 1);

                return $receipt->fresh();
            });
        } catch (Throwable $e) {
            Storage::disk('local')->delete($storedPath);
            throw $e;
        }
    }

    public function getOwnedReceipt(User $user, string $receiptId): Receipt
    {
        $receipt = Receipt::query()->find($receiptId);
        if ($receipt === null) {
            throw new NotFoundHttpException('Receipt not found.');
        }

        if ($receipt->user_id !== $user->id) {
            throw new OwnershipViolationException('You do not have access to this receipt.');
        }

        return $receipt;
    }

    public function deleteReceipt(User $user, string $receiptId): void
    {
        $receipt = $this->getOwnedReceipt($user, $receiptId);
        $filePath = $receipt->file_path;

        $this->ledgerService->executeAtomically(function () use ($user, $receipt) {
            $receipt->version = $receipt->version + 1;
            $receipt->save();
            $receipt->delete();

            $this->syncRecorder->recordSyncChange($user->id, 'receipts', $receipt->id, 'delete', $receipt->version);
        });

        if ($filePath && Storage::disk('local')->exists($filePath)) {
            Storage::disk('local')->delete($filePath);
        }
    }
}
