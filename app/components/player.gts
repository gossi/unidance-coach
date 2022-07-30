import Component from '@glimmer/component';
import { service, Registry as Services } from '@ember/service';
import SpotifyPlayer from '../player/spotify';
import Spotify from './player/spotify';
import styles from './player.css';

export default class PlayerComponent extends Component {
  @service declare player: Services['player'];

  get spotify() {
    return this.player.player instanceof SpotifyPlayer;
  }

  <template>
    {{#if this.spotify}}
      <div class={{styles.player}}>
        <Spotify />
      </div>
    {{/if}}
  </template>
}

declare module '@glint/environment-ember-loose/registry' {
  export default interface Registry {
    Player: typeof PlayerComponent;
  }
}
