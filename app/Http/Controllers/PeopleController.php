<?php

namespace App\Http\Controllers;

use App\Http\Resources\PersonResource;
use App\Models\Person;
use App\Models\Reaction;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use OpenApi\Annotations as OA;

/**
 * @OA\Tag(
 *     name="People",
 *     description="People recommendations and reactions"
 * )
 */
class PeopleController extends Controller
{
    /**
     * @OA\Get(
     *     path="/api/people",
     *     summary="List recommended people",
     *     tags={"People"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="per_page",
     *         in="query",
     *         description="Results per page (max 50)",
     *         required=false,
     *         @OA\Schema(type="integer", example=10)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Paginated list of recommended people",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="data",
     *                 type="array",
     *                 @OA\Items(ref="#/components/schemas/PersonResource")
     *             )
     *         )
     *     )
     * )
     */
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'per_page' => ['nullable', 'integer', 'min:1', 'max:50'],
        ]);

        $perPage = $validated['per_page'] ?? 10;
        $user = $request->user('api');

        $people = Person::query()
            ->with(['reactions' => static function ($query) use ($user) {
                $query->where('user_id', $user->id);
            }])
            ->where('user_id', '!=', $user->id)
            ->orderByDesc('likes_count')
            ->orderBy('id')
            ->paginate($perPage)
            ->withQueryString();

        return PersonResource::collection($people)->response();
    }

    /**
     * @OA\Get(
     *     path="/api/people/liked",
     *     summary="List people liked by the current user",
     *     tags={"People"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Paginated list of liked people",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="data",
     *                 type="array",
     *                 @OA\Items(ref="#/components/schemas/PersonResource")
     *             )
     *         )
     *     )
     * )
     */
    public function liked(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'per_page' => ['nullable', 'integer', 'min:1', 'max:50'],
        ]);

        $perPage = $validated['per_page'] ?? 10;
        $user = $request->user('api');

        $people = Person::query()
            ->whereHas('reactions', static function ($query) use ($user) {
                $query->where('user_id', $user->id)->where('type', 'like');
            })
            ->with(['reactions' => static function ($query) use ($user) {
                $query->where('user_id', $user->id);
            }])
            ->where('user_id', '!=', $user->id)
            ->orderByDesc('likes_count')
            ->orderBy('id')
            ->paginate($perPage)
            ->withQueryString();

        return PersonResource::collection($people)->response();
    }

    /**
     * @OA\Post(
     *     path="/api/people/{person}/like",
     *     summary="Like a person",
     *     tags={"People"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="person",
     *         in="path",
     *         required=true,
     *         description="Person identifier",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Person liked",
     *         @OA\JsonContent(ref="#/components/schemas/PersonResource")
     *     ),
     *     @OA\Response(response=403, description="Cannot react to own profile")
     * )
     */
    public function like(Request $request, Person $person): JsonResponse
    {
        return $this->react($request, $person, 'like');
    }

    /**
     * @OA\Post(
     *     path="/api/people/{person}/dislike",
     *     summary="Dislike a person",
     *     tags={"People"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="person",
     *         in="path",
     *         required=true,
     *         description="Person identifier",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Person disliked",
     *         @OA\JsonContent(ref="#/components/schemas/PersonResource")
     *     ),
     *     @OA\Response(response=403, description="Cannot react to own profile")
     * )
     */
    public function dislike(Request $request, Person $person): JsonResponse
    {
        return $this->react($request, $person, 'dislike');
    }

    private function react(Request $request, Person $person, string $type): JsonResponse
    {
        $user = $request->user('api');

        if ($person->user_id === $user->id) {
            return response()->json([
                'message' => 'You cannot react to your own profile.',
            ], 403);
        }

        DB::transaction(function () use ($person, $type, $user): void {
            $existingReaction = Reaction::query()
                ->where('person_id', $person->id)
                ->where('user_id', $user->id)
                ->lockForUpdate()
                ->first();

            if ($existingReaction) {
                $previousType = $existingReaction->type;

                if ($previousType === $type) {
                    return;
                }

                $existingReaction->update(['type' => $type]);
                $this->syncReactionCounters($person, $previousType, $type);
            } else {
                Reaction::create([
                    'person_id' => $person->id,
                    'user_id' => $user->id,
                    'type' => $type,
                ]);

                $this->syncReactionCounters($person, null, $type);
            }
        });

        $person->refresh()->load(['reactions' => static function ($query) use ($user) {
            $query->where('user_id', $user->id);
        }]);

        return (new PersonResource($person))->response();
    }

    private function syncReactionCounters(Person $person, ?string $previous, string $current): void
    {
        if ($previous === $current) {
            return;
        }

        if ($previous === 'like') {
            if ($person->likes_count > 0) {
                $person->decrement('likes_count');
            }
        }

        if ($previous === 'dislike') {
            if ($person->dislikes_count > 0) {
                $person->decrement('dislikes_count');
            }
        }

        if ($current === 'like') {
            $person->increment('likes_count');
        }

        if ($current === 'dislike') {
            $person->increment('dislikes_count');
        }
    }
}
