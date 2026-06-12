<?php
// app/Http/Resources/AnnouncementResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AnnouncementResource extends JsonResource
{
    public function __construct($resource, private bool $full = false)
    {
        parent::__construct($resource);
    }

    public function toArray(Request $request): array
    {
        return [
            'id'                    => $this->id,
            'title'                 => $this->title,
            'content_preview'       => $this->contentPreview(),
            'body'                  => $this->when($this->full, $this->body),
            'category'              => $this->category,
            'category_label'        => $this->categoryLabel(),
            'category_color'        => $this->categoryColor(),
            'is_urgent'             => $this->is_urgent,
            'author_name'           => $this->author?->name ?? 'Admin',
            'published_at'          => $this->published_at?->toIso8601String(),
            'published_at_formatted'=> $this->published_at?->locale('id')->isoFormat('D MMM YYYY'),
            'expires_at'            => $this->expires_at?->toIso8601String(),
        ];
    }

    private function contentPreview(): string
    {
        $text = $this->body ?? '';
        return mb_strlen($text) > 200
            ? mb_substr($text, 0, 200) . '...'
            : $text;
    }

    private function categoryLabel(): string
    {
        return match ($this->category) {
            'academic' => 'Akademik',
            'event'    => 'Event',
            'seminar'  => 'Seminar',
            'urgent'   => 'Urgent',
            default    => 'Umum',
        };
    }

    private function categoryColor(): string
    {
        return match ($this->category) {
            'academic' => '#6366F1',
            'event'    => '#10B981',
            'seminar'  => '#06B6D4',
            'urgent'   => '#EF4444',
            default    => '#9CA3AF',
        };
    }
}
