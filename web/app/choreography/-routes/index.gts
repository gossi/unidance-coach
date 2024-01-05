import { Route } from 'ember-polaris-routing';
import CompatRoute from 'ember-polaris-routing/route/compat';

export class ChoreographyIndexRoute extends Route<{}> {
  <template>
    <blockquote>
      <b>Choreographie</b>
      ist die Kunst und das Handwerk Bewegungenssequenzen zu designen. In einer
      <i>Choreographie</i>
      sind Bewegungsablauf, -form oder beides
      <i>niedergeschrieben</i>.
    </blockquote>
  </template>
}

export default CompatRoute(ChoreographyIndexRoute);
