<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Customer extends Model
{
    use HasFactory;

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'full_name', 'email', 'shipping_address', 'billing_address',
    ];

    protected $casts = [
        'full_name' => 'encrypted',
        'email' => 'encrypted',
        'shipping_address' => 'encrypted:array',
        'billing_address' => 'encrypted:array',
    ];
}
