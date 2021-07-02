interface ItemsPerRow {
  readonly numColumns: number;
  readonly spacing: number;
  readonly itemWidth: number;
}

export function calculateItemsPerRow(
  itemSize: number,
  spacing: number,
  listSize: number
): ItemsPerRow {
  const numColumns = Math.round((listSize - spacing) / (itemSize + spacing));

  const total = (itemSize + spacing) * numColumns;
  console.log('====', listSize, numColumns, total);
  return {
    numColumns,
    spacing: spacing,
    itemWidth: itemSize,
  };
}

export function calculateItemWidth(
  numColumns: number,
  spacing: number,
  listSize: number
): ItemsPerRow {
  let totalSpacing = (numColumns + 1) * spacing;
  let width = Math.floor((listSize - totalSpacing) / numColumns);
  console.log(
    '🔦',
    'listSize',
    listSize,
    'column',
    numColumns,
    'totalS: ',
    totalSpacing,
    'w',
    width
  );
  return {
    numColumns: numColumns,
    itemWidth: width,
    spacing: spacing,
  };
}
