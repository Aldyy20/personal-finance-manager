<?php

namespace App\Exceptions;

use RuntimeException;

class FinancialValidationException extends RuntimeException
{
    /**
     * @param  array<string, list<string>|string>  $errors
     */
    public function __construct(
        string $message,
        public readonly array $errors = [],
    ) {
        parent::__construct($message);
    }
}

