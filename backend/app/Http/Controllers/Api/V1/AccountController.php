<?php

namespace App\Http\Controllers\Api\V1;

use App\Exceptions\OwnershipViolationException;
use App\Http\Requests\Api\V1\Account\StoreAccountRequest;
use App\Http\Requests\Api\V1\Account\StoreAdjustmentRequest;
use App\Http\Requests\Api\V1\Account\UpdateAccountRequest;
use App\Http\Resources\Api\V1\AccountAdjustmentResource;
use App\Http\Resources\Api\V1\AccountMovementResource;
use App\Http\Resources\Api\V1\AccountResource;
use App\Models\Account;
use App\Models\AccountMovement;
use App\Services\AccountService;
use App\Services\LedgerService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class AccountController extends ApiController
{
    public function __construct(
        private readonly AccountService $accountService,
        private readonly LedgerService $ledgerService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = Account::query()
            ->where('user_id', $request->user()->id)
            ->orderByDesc('is_active')
            ->orderBy('name');

        if ($request->has('is_active')) {
            $query->where('is_active', filter_var($request->query('is_active'), FILTER_VALIDATE_BOOLEAN));
        }

        if ($request->filled('account_type')) {
            $query->where('account_type', (string) $request->query('account_type'));
        }

        return $this->success(
            data: AccountResource::collection($query->get()),
            message: 'Accounts retrieved',
        );
    }

    public function store(StoreAccountRequest $request): JsonResponse
    {
        $account = $this->accountService->createAccount($request->user(), $request->validated());

        return $this->success(
            data: new AccountResource($account),
            message: 'Account created',
            status: 201,
        );
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $account = $this->findOwnedAccount($request, $id);

        return $this->success(
            data: new AccountResource($account),
            message: 'Account retrieved',
        );
    }

    public function update(UpdateAccountRequest $request, string $id): JsonResponse
    {
        $validated = $request->validated();
        $baseVersion = isset($validated['base_version']) ? (int) $validated['base_version'] : null;

        $account = $this->accountService->updateAccount($request->user(), $id, $validated, $baseVersion);

        return $this->success(
            data: new AccountResource($account),
            message: 'Account updated',
        );
    }

    public function archive(Request $request, string $id): JsonResponse
    {
        $baseVersion = $request->filled('base_version') ? (int) $request->input('base_version') : null;
        $account = $this->accountService->archiveAccount($request->user(), $id, $baseVersion);

        return $this->success(
            data: new AccountResource($account),
            message: 'Account archived',
        );
    }

    public function restore(Request $request, string $id): JsonResponse
    {
        $baseVersion = $request->filled('base_version') ? (int) $request->input('base_version') : null;
        $account = $this->accountService->restoreAccount($request->user(), $id, $baseVersion);

        return $this->success(
            data: new AccountResource($account),
            message: 'Account restored',
        );
    }

    public function movements(Request $request, string $id): JsonResponse
    {
        $account = $this->findOwnedAccount($request, $id);
        $perPage = max(1, min(100, (int) $request->query('per_page', 20)));

        $movements = AccountMovement::query()
            ->where('account_id', $account->id)
            ->orderByDesc('created_at')
            ->paginate($perPage);

        return $this->success(
            data: AccountMovementResource::collection($movements->items()),
            message: 'Account movements retrieved',
            meta: [
                'current_page' => $movements->currentPage(),
                'per_page' => $movements->perPage(),
                'total' => $movements->total(),
                'last_page' => $movements->lastPage(),
            ],
        );
    }

    public function balance(Request $request, string $id): JsonResponse
    {
        $account = $this->findOwnedAccount($request, $id);
        $ledgerBalance = $this->ledgerService->calculateLedgerBalance($account->id);

        return $this->success(
            data: [
                'account_id' => $account->id,
                'balance' => $ledgerBalance,
                'balance_cache' => (int) $account->balance_cache,
                'is_reconciled' => $ledgerBalance === (int) $account->balance_cache,
            ],
            message: 'Account balance retrieved',
        );
    }

    public function storeAdjustment(StoreAdjustmentRequest $request, string $id): JsonResponse
    {
        $adjustment = $this->accountService->createAdjustment(
            $request->user(),
            $id,
            $request->validated()
        );

        return $this->success(
            data: new AccountAdjustmentResource($adjustment),
            message: 'Account adjustment recorded',
            status: 201,
        );
    }

    private function findOwnedAccount(Request $request, string $id): Account
    {
        $account = Account::query()->find($id);
        if ($account === null) {
            throw new NotFoundHttpException('Account not found.');
        }

        if ($account->user_id !== $request->user()->id) {
            throw new OwnershipViolationException('You do not have access to this account.');
        }

        return $account;
    }
}

