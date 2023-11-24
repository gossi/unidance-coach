import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';

import { Resource } from 'ember-resources';

import type { Playlist, Track } from '../domain-objects';
import type SpotifyService from '../service';
import type { ArgsWrapper } from 'ember-resources';

interface PlaylistArgs extends ArgsWrapper {
  named: {
    playlist: string;
  };
}

export class PlaylistResource extends Resource<PlaylistArgs> {
  @service declare spotify: SpotifyService;

  declare playlistId: string;

  @tracked playlist?: Playlist;

  get tracks(): Track[] | undefined {
    return this.playlist?.tracks?.items.map((tracks) => tracks.track as Track);
  }

  modify(_positional: PlaylistArgs['positional'], named: PlaylistArgs['named']): void {
    this.playlistId = named.playlist;

    this.load();
  }

  async load() {
    const response = await this.spotify.client.api.getPlaylist(this.playlistId);

    this.playlist = response;
  }
}
