import { pageTitle } from 'ember-page-title';
import { service } from '@ember/service';
import { on } from '@ember/modifier';

import { Assistant, buildAssistantLink } from '../../../assistants';

import { Route } from 'ember-polaris-routing';
import CompatRoute from 'ember-polaris-routing/route/compat';

import type { LinkManagerService } from 'ember-link';
import type RouterService from '@ember/routing/router-service';

export class TrainingPlanningGamesRoute extends Route<{}> {
  @service declare linkManager: LinkManagerService;
  @service('router') declare emberRouter: RouterService;

  <template>
    {{pageTitle "Assistenten"}}

    <h1>Hilfsmittel</h1>

    <ul>
      {{#let (buildAssistantLink Assistant.DanceMix) as |link|}}
        <li>
          <a href={{link.url}} {{on 'click' link.open}}>Dance Mix</a><br>
          Super Mix zum Freestylen. Einmal anschalten und die Jukebox geht los.
          Wechselt den Song für genügend Abwechselung. Super Training für die
          ganze Gruppe.
        </li>
      {{/let}}

      {{#let (buildAssistantLink Assistant.Looper) as |link|}}
        <li>
          <a href={{link.url}} {{on 'click' link.transitionTo}}>Loops</a><br>
          Die gleiche Sequenz von einem Lied? Immer und immer wieder? Genau das
          sind Loops, ideal zum einstudieren von kurzen Choreos.
        </li>
      {{/let}}
    </ul>
  </template>
}

export default CompatRoute(TrainingPlanningGamesRoute);
