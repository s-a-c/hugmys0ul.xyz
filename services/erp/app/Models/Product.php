<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'sku', 'name', 'description', 'images', 'base_price', 'cost', 'supplier_info',
    ];

    protected $casts = [
        'images' => 'array',
        'supplier_info' => 'array',
        'base_price' => 'decimal:2',
        'cost' => 'decimal:2',
    ];

    public function inventory()
    {
        return $this->hasOne(Inventory::class);
    }
}
