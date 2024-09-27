enum Side {
  BUY('buy', 1),
  SELL('sell', -1);

  final String description;
  final int value;

  const Side(this.description, this.value);
}
