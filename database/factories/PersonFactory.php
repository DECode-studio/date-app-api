<?php

namespace Database\Factories;

use App\Models\Person;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Person>
 */
class PersonFactory extends Factory
{
    protected $model = Person::class;

    public function definition(): array
    {
        $faker = $this->faker;

        $portraitIndex = $faker->numberBetween(1, 90);
        $secondaryIndex = (($portraitIndex + 7 - 1) % 90) + 1;

        return [
            'user_id' => User::factory(),
            'name' => $faker->name('female'),
            'age' => $faker->numberBetween(21, 42),
            'pictures' => [
                sprintf('https://randomuser.me/api/portraits/women/%d.jpg', $portraitIndex),
                sprintf('https://randomuser.me/api/portraits/women/%d.jpg', $secondaryIndex)
            ],
            'location' => $faker->city(),
            'likes_count' => $faker->numberBetween(0, 40),
            'dislikes_count' => $faker->numberBetween(0, 10),
        ];
    }
}
