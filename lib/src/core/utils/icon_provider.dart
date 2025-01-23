enum IconProvider {
  splash(imageName: 'splash.png'),
  logo(imageName: 'logo.png'),
  achievement(imageName: 'achievement.png'),
  arrow(imageName: 'arrow.png'),
  background(imageName: 'background.png'),
  balloon(imageName: 'balloon.png'),
  coins(imageName: 'coins.png'),
  daily(imageName: 'daily.png'),
  detector(imageName: 'detecter.png'),
  mins(imageName: 'mins.png'),
  rocket(imageName: 'rocket.png'),
  shield(imageName: 'shield.png'),
  star(imageName: 'star.png'),
  gift(imageName: 'gift.png'),
  lock(imageName: 'lock.png'),
  time(imageName: 'time.png'),
  panel(imageName: 'panel.png'),
  btn1(imageName: 'btn1.png'),

  unknown(imageName: '');

  const IconProvider({
    required this.imageName,
  });

  final String imageName;
  static const _imageFolderPath = 'assets/images';

  String buildImageUrl() => '$_imageFolderPath/$imageName';
  static String buildImageByName(String name) => '$_imageFolderPath/$name';
}
