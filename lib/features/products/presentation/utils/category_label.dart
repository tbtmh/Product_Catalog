String categoryLabel(String slug) => slug
    .split('-')
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');
