@php
    /** @var \App\Models\Person $person */
@endphp

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Popular Person Notification</title>
</head>
<body>
    <p>Hi Admin,</p>

    <p><strong>{{ $person->name }}</strong> has reached {{ $person->likes_count }} likes.</p>

    @if (!empty($person->location))
        <p>Location: {{ $person->location }}</p>
    @endif

    <p>Thank you,<br>Dating App</p>
</body>
</html>
