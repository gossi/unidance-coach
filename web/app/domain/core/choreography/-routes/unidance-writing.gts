import { pageTitle } from 'ember-page-title';
import { Route } from 'ember-polaris-routing';
import CompatRoute from 'ember-polaris-routing/route/compat';

export class ChoreographyUniDanceWritingRoute extends Route<object> {
  <template>
    {{pageTitle "UniDance Writing"}}

    <h2>UniDance Writing</h2>

    <p>Der Begriff
      <b>Choreographie</b>
      bedeutet wörtlich "Tanz-Schreiben" und leitet sich aus dem griechischen ”χορεία” (khorós =
      Tanz) und ”γραφή” (gráphō = schreiben) ab. Im Tanzen haben sich unter dem Begriff
      <i>Dance Writing</i>
      Schablonen geformt, mit denen eine Choreographie auf Papier gebracht werden kann (ähnlich der
      Noten für ein Musikstück).
    </p><p>
      Mit
      <b>UniDance Writing</b>
      hat David Weichenberger an der Freestyle Convention (2015) den Transfer zum Einradfahren
      geschlagen. In dieser Diskussionsrunde kristallisierten sich unterschiedliche Formate für
      verschiedene Verwendungszwecke heraus.
    </p>

    tbd.
  </template>
}

// @ts-expect-error some broken upstream types here
export default CompatRoute(ChoreographyUniDanceWritingRoute);
