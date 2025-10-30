<?php

namespace App\Console\Commands;

use App\Mail\PersonHitThreshold;
use App\Models\Person;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Mail;

class NotifyPopularPeople extends Command
{
    protected $signature = 'notify:popular-people';

    protected $description = 'Send notification emails when a person crosses the like threshold.';

    public function handle(): int
    {
        $threshold = (int) config('services.popular_person_threshold', 50);
        $adminEmail = config('services.admin_email', env('ADMIN_EMAIL', 'admin@example.com'));

        if (empty($adminEmail)) {
            $this->warn('Admin email is not configured. Skipping notifications.');

            return self::SUCCESS;
        }

        Person::query()
            ->whereNull('notified_at')
            ->where('likes_count', '>=', $threshold)
            ->chunkById(50, function ($people) use ($adminEmail): void {
                foreach ($people as $person) {
                    Mail::to($adminEmail)->queue(new PersonHitThreshold($person));

                    $person->forceFill(['notified_at' => now()])->save();
                    $this->info("Notification queued for {$person->name} (ID: {$person->id}).");
                }
            });

        return self::SUCCESS;
    }
}
