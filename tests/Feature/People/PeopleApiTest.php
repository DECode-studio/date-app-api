<?php

namespace Tests\Feature\People;

use App\Models\Person;
use App\Models\Reaction;
use App\Models\User;
use Tests\TestCase;

class PeopleApiTest extends TestCase
{
    public function test_index_returns_recommended_people(): void
    {
        $user = User::factory()->create();

        $recommended = Person::factory()->count(3)->create();
        $ownProfile = Person::factory()->for($user)->create();

        $response = $this->getJson('/api/people', $this->apiHeadersFor($user));

        $response
            ->assertOk()
            ->assertJsonStructure([
                'data' => [
                    [
                        'id',
                        'name',
                        'age',
                        'pictures',
                        'location',
                        'likes_count',
                        'dislikes_count',
                        'reaction',
                        'created_at',
                        'updated_at',
                    ],
                ],
            ]);

        $returnedIds = collect($response->json('data'))->pluck('id');

        $this->assertCount(3, $returnedIds);
        $this->assertFalse($returnedIds->contains($ownProfile->id));
        $this->assertEqualsCanonicalizing($recommended->pluck('id')->all(), $returnedIds->all());
    }

    public function test_liked_returns_people_liked_by_current_user(): void
    {
        $user = User::factory()->create();
        $likedPerson = Person::factory()->create();
        $dislikedPerson = Person::factory()->create();

        Reaction::create([
            'person_id' => $likedPerson->id,
            'user_id' => $user->id,
            'type' => 'like',
        ]);

        Reaction::create([
            'person_id' => $dislikedPerson->id,
            'user_id' => $user->id,
            'type' => 'dislike',
        ]);

        $response = $this->getJson('/api/people/liked', $this->apiHeadersFor($user));

        $response->assertOk();

        $returnedIds = collect($response->json('data'))->pluck('id');

        $this->assertTrue($returnedIds->contains($likedPerson->id));
        $this->assertFalse($returnedIds->contains($dislikedPerson->id));
    }

    public function test_like_creates_reaction_and_updates_counters(): void
    {
        $user = User::factory()->create();
        $person = Person::factory()->create([
            'likes_count' => 0,
            'dislikes_count' => 0,
        ]);

        $response = $this->postJson("/api/people/{$person->id}/like", [], $this->apiHeadersFor($user));

        $response
            ->assertOk()
            ->assertJsonPath('data.reaction', 'like');

        $this->assertDatabaseHas('reactions', [
            'person_id' => $person->id,
            'user_id' => $user->id,
            'type' => 'like',
        ]);

        $this->assertDatabaseHas('people', [
            'id' => $person->id,
            'likes_count' => 1,
            'dislikes_count' => 0,
        ]);
    }

    public function test_switching_reaction_updates_counters(): void
    {
        $user = User::factory()->create();
        $person = Person::factory()->create([
            'likes_count' => 0,
            'dislikes_count' => 1,
        ]);

        Reaction::create([
            'person_id' => $person->id,
            'user_id' => $user->id,
            'type' => 'dislike',
        ]);

        $response = $this->postJson("/api/people/{$person->id}/like", [], $this->apiHeadersFor($user));

        $response
            ->assertOk()
            ->assertJsonPath('data.reaction', 'like');

        $this->assertDatabaseHas('reactions', [
            'person_id' => $person->id,
            'user_id' => $user->id,
            'type' => 'like',
        ]);

        $this->assertDatabaseHas('people', [
            'id' => $person->id,
            'likes_count' => 1,
            'dislikes_count' => 0,
        ]);
    }

    public function test_cannot_react_to_own_profile(): void
    {
        $user = User::factory()->create();
        $person = Person::factory()->for($user)->create();

        $response = $this->postJson("/api/people/{$person->id}/like", [], $this->apiHeadersFor($user));

        $response
            ->assertForbidden()
            ->assertJson([
                'message' => 'You cannot react to your own profile.',
            ]);

        $this->assertDatabaseMissing('reactions', [
            'person_id' => $person->id,
            'user_id' => $user->id,
        ]);
    }
}
