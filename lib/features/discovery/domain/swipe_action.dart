enum SwipeAction {
  like,
  pass,
  superLike;

  String get label {
    switch (this) {
      case SwipeAction.like:
        return 'Like';
      case SwipeAction.pass:
        return 'Pass';
      case SwipeAction.superLike:
        return 'Super Like';
    }
  }
}
