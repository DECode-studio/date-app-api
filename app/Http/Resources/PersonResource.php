<?php

namespace App\Http\Resources;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use OpenApi\Annotations as OA;

/**
 * @OA\Schema(
 *     schema="PersonResource",
 *     type="object",
 *     @OA\Property(property="id", type="integer"),
 *     @OA\Property(property="name", type="string"),
 *     @OA\Property(property="age", type="integer"),
 *     @OA\Property(property="pictures", type="array", @OA\Items(type="string")),
 *     @OA\Property(property="location", type="string", nullable=true),
 *     @OA\Property(property="likes_count", type="integer"),
 *     @OA\Property(property="dislikes_count", type="integer"),
 *     @OA\Property(property="notified_at", type="string", format="date-time", nullable=true),
 *     @OA\Property(property="reaction", type="string", nullable=true, enum={"like","dislike"}),
 *     @OA\Property(property="created_at", type="string", format="date-time", nullable=true),
 *     @OA\Property(property="updated_at", type="string", format="date-time", nullable=true)
 * )
 */
class PersonResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $reaction = null;

        if ($this->resource instanceof Model && $this->resource->relationLoaded('reactions')) {
            $reaction = $this->resource->getRelation('reactions')->first();
        }

        return [
            'id' => $this->id,
            'name' => $this->name,
            'age' => $this->age,
            'pictures' => $this->pictures ?? [],
            'location' => $this->location,
            'likes_count' => $this->likes_count,
            'dislikes_count' => $this->dislikes_count,
            'notified_at' => optional($this->notified_at)?->toISOString(),
            'reaction' => $reaction?->type,
            'created_at' => optional($this->created_at)?->toISOString(),
            'updated_at' => optional($this->updated_at)?->toISOString(),
        ];
    }
}
