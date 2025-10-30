<?php

namespace Database\Seeders;

use App\Models\Person;
use Illuminate\Database\Seeder;

class PeopleSeeder extends Seeder
{
    public function run(): void
    {
        Person::factory()
            ->count(20)
            ->state(fn () => [
                'likes_count' => 0,
                'dislikes_count' => 0,
            ])
            ->create();

        Person::factory()
            ->state(fn () => [
                'likes_count' => 55,
                'dislikes_count' => 3,
            ])
            ->create();
    }
}
