import type { ImageSourcePropType } from 'react-native';
import { animalsLevel, type Level } from './levels';

export type PageDefinition = {
  id: string;
  title: string;
  thumbnail: ImageSourcePropType;
  level?: Level;
};

export type BookDefinition = {
  id: string;
  title: string;
  cover: ImageSourcePropType;
  wallpaper: ImageSourcePropType;
  pages: PageDefinition[];
};

const animalsThumbnail = require('../../assets/animals-card.png');

export const animalsBook: BookDefinition = {
  id: 'animals',
  title: 'Animals',
  cover: animalsThumbnail,
  wallpaper: require('../../assets/animals-wallpaper.png'),
  pages: Array.from({ length: 10 }, (_, index) => ({
    id: `animals-${index + 1}`,
    title: `Page ${index + 1}`,
    thumbnail: animalsThumbnail,
    level: index === 0 ? animalsLevel : undefined,
  })),
};

export const books: BookDefinition[] = [animalsBook];
