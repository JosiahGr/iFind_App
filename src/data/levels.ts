import { ImageSourcePropType } from 'react-native';

export type Target = {
  id: string;
  label: string;
  thumbnail: ImageSourcePropType;
  rect: { x: number; y: number; width: number; height: number };
};

export type Level = {
  id: string;
  title: string;
  scene: ImageSourcePropType;
  sceneWidth: number;
  sceneHeight: number;
  targets: Target[];
};

export const animalsLevel: Level = {
  id: 'animals-1',
  title: 'Animals · Page 1',
  scene: require('../../assets/animal-scene.png'),
  sceneWidth: 1664,
  sceneHeight: 768,
  targets: [
    {
      id: 'bear',
      label: 'Bear',
      thumbnail: require('../../assets/target-bear.png'),
      rect: { x: 0.23, y: 0.58, width: 0.132, height: 0.339 },
    },
    {
      id: 'bird',
      label: 'Bird',
      thumbnail: require('../../assets/target-bird.png'),
      rect: { x: 0.48, y: 0.58, width: 0.132, height: 0.339 },
    },
    {
      id: 'penguin',
      label: 'Penguin',
      thumbnail: require('../../assets/target-penguin.png'),
      rect: { x: 0.36, y: 0.08, width: 0.132, height: 0.339 },
    },
    {
      id: 'lion',
      label: 'Lion',
      thumbnail: require('../../assets/target-lion.png'),
      rect: { x: 0.087, y: 0.208, width: 0.132, height: 0.339 },
    },
    {
      id: 'monkey',
      label: 'Monkey',
      thumbnail: require('../../assets/target-monkey.png'),
      rect: { x: 0.60, y: 0.142, width: 0.132, height: 0.339 },
    },
    {
      id: 'rabbit',
      label: 'Rabbit',
      thumbnail: require('../../assets/target-rabbit.png'),
      rect: { x: 0.859, y: 0.162, width: 0.132, height: 0.339 },
    },
  ],
};
