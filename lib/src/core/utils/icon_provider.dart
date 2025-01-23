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
  btn1(imageName: 'big_button.png'),
  smallButton(imageName: 'small_button.png'),
  greenButton(imageName: 'green_button.png'),
  starGrey(imageName: 'star_grey.png'),
  level(imageName: 'level.png'),

  unknown(imageName: '');

  const IconProvider({
    required this.imageName,
  });

  final String imageName;
  static const _imageFolderPath = 'assets/images';

  String buildImageUrl() => '$_imageFolderPath/$imageName';
  static String buildImageByName(String name) => '$_imageFolderPath/$name';
}
