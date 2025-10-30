<?php

namespace App\Mail;

use App\Models\Person;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class PersonHitThreshold extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public function __construct(public Person $person)
    {
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Popular Person Notification',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'mail.person_hit_threshold',
            with: [
                'person' => $this->person,
            ],
        );
    }

    /**
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [];
    }
}
