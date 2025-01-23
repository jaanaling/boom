enum RouteValue {
  splash(
    path: '/',
  ),
  home(
    path: '/home',
  ),
  select(
    path: 'select',
  ),
  game(
    path: 'game',
  ),
  achievement(
    path: 'achievement',
  ),

  privacy(path: '/privacy'),

  unknown(
    path: '',
  );

  final String path;
  const RouteValue({
    required this.path,
  });
}
