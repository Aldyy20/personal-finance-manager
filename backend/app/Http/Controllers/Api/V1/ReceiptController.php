<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\Api\V1\Receipt\UploadReceiptRequest;
use App\Http\Resources\Api\V1\ReceiptResource;
use App\Services\ReceiptService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class ReceiptController extends ApiController
{
    public function __construct(
        private readonly ReceiptService $receiptService,
    ) {}

    public function store(UploadReceiptRequest $request): JsonResponse
    {
        $receipt = $this->receiptService->uploadReceipt(
            $request->user(),
            $request->file('file'),
            $request->validated()
        );

        return $this->success(
            data: new ReceiptResource($receipt),
            message: 'Receipt uploaded',
            status: 201,
        );
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $receipt = $this->receiptService->getOwnedReceipt($request->user(), $id);

        return $this->success(
            data: new ReceiptResource($receipt),
            message: 'Receipt metadata retrieved',
        );
    }

    public function download(Request $request, string $id): BinaryFileResponse
    {
        $receipt = $this->receiptService->getOwnedReceipt($request->user(), $id);
        $disk = Storage::disk('local');

        if (! $disk->exists($receipt->file_path)) {
            throw new NotFoundHttpException('Receipt file not found on storage.');
        }

        return response()->download(
            $disk->path($receipt->file_path),
            $receipt->file_name ?? basename($receipt->file_path),
            ['Content-Type' => $receipt->mime_type]
        );
    }

    public function destroy(Request $request, string $id): JsonResponse
    {
        $this->receiptService->deleteReceipt($request->user(), $id);

        return $this->success(message: 'Receipt removed');
    }
}

