import { DanceMixParam, DanceMixParams } from './dance-mix';

export enum Game {
  DanceMix = 'dance-mix'
}

export type GameNames = keyof Games;

export const ALL_GAME_PARAMS = [...Object.values(DanceMixParam)];

export interface Games {
  'dance-mix': DanceMixParams;
}
