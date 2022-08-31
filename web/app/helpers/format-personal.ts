import { helper } from '@ember/component/helper';
import { Personal } from '../database/exercises';
import { getIcon, Icons } from '../components/icon';

export function formatPersonalIcon(personal: Personal) {
  return getIcon(personal as Icons);
}

export function formatPersonalText(personal: Personal) {
  switch (personal) {
    case 'individual':
      return 'Einzel';

    case 'pair':
      return 'Paar';

    case 'group':
      return 'Gruppe';
  }
}

const DEFAULT = { icon: true, text: false };

export function formatPersonal(
  [personal]: [Personal],
  options: { icon: boolean; text: boolean }
) {
  options = { ...DEFAULT, ...options };
  const out = [];

  if (options.icon) {
    out.push(formatPersonalIcon(personal));
  }

  if (options.text) {
    out.push(formatPersonalText(personal));
  }
  return out.join(' ');
}

export interface FormatPersonalSignature {
  Args: {
    Positional: [Personal];
    Named: { icon?: boolean; text?: boolean };
  };
  Return: string;
}

const formatPersonalHelper = helper<FormatPersonalSignature>(formatPersonal);

export default formatPersonalHelper;

declare module '@glint/environment-ember-loose/registry' {
  export default interface Registry {
    'format-personal': typeof formatPersonalHelper;
  }
}
