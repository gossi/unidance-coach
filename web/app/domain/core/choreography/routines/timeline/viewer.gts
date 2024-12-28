import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { registerDestructor } from '@ember/destroyable';
import { uniqueId } from '@ember/helper';

import { modifier } from 'ember-modifier';
import { DataSet } from 'vis-data/esnext';
import { Timeline } from 'vis-timeline/esnext';

import { dateToSecondsWithMilli } from '../../../../supporting/utils';
import { YoutubePlayer } from '../../../../supporting/youtube';
import { groups, type TimeTracking } from './domain';
import styles from './timeline.css';

import type { YoutubePlayerAPI } from '../../../../supporting/youtube';
import type Owner from '@ember/owner';
import type { DataItem, TimelineOptions } from 'vis-timeline/esnext';

interface TimelineViewerSignature {
  Element: HTMLElement;
  Args: {
    active: boolean;
    routine: TimeTracking;
    options?: TimelineOptions;
    video?: string;
    redraw?: boolean;
    playerApi?: YoutubePlayerAPI;
    setChartApi?: (chart: Timeline, data: DataSet<DataItem>) => void;
    seeked?: (currentTime: number) => void;
  };
}

export class TimelineViewer extends Component<TimelineViewerSignature> {
  declare player: YoutubePlayerAPI;
  declare chart: Timeline;

  @tracked duration?: number;
  @tracked currentTime?: number;

  data = new DataSet<DataItem>();

  constructor(owner: Owner, args: TimelineViewerSignature['Args']) {
    super(owner, args);

    try {
      document.body.addEventListener('keyup', this.handleKeyboard.bind(this));

      registerDestructor(this, () => {
        document.body.removeEventListener('keyup', this.handleKeyboard.bind(this));
      });
    } catch {
      /**/
    }
  }

  setPlayerApi = (api: YoutubePlayerAPI) => {
    this.player = api;
    this.player.on('seek', this.seeked.bind(this));

    this.init();
  };

  init = async () => {
    this.duration = await this.player.getDuration();
    this.currentTime = await this.player.getCurrentTime();

    this.chart.setOptions({
      end: this.duration * 1000,
      max: this.duration * 1000,
      zoomMax: this.duration * 1000
    });

    const seek = async ({ id, time }: { id: string; time: Date }) => {
      if (id === 'currentTime') {
        const ms = dateToSecondsWithMilli(time);

        const seekTo = ms <= 0 ? 0 : Math.min(ms, this.duration as number);

        if (ms <= 0) {
          this.chart.setCustomTime(0, 'currentTime');
        } else if (ms >= (this.duration as number)) {
          this.chart.setCustomTime((this.duration as number) * 1000, 'currentTime');
        } else {
          this.player.seekTo(seekTo, true);
        }
      }
    };

    this.chart.on('timechange', seek);
    this.chart.on('timechanged', seek);

    for (const [group, datapoints] of Object.entries(this.args.routine.groups ?? {})) {
      this.data.add(
        datapoints.map((v) => ({
          id: uniqueId(),
          content: '',
          start: v[0] * 1000,
          end: v[1] * 1000,
          group
        }))
      );
    }

    if (this.args.routine.start) {
      this.data.add({
        id: 'start',
        content: 'Start',
        start: this.args.routine.start * 1000,
        group: 'marker'
      });
    }

    if (this.args.routine.end) {
      this.data.add({
        id: 'end',
        content: 'Ende',
        start: this.args.routine.end * 1000,
        group: 'marker'
      });
    }
  };

  seeked = (currentTime: number) => {
    this.currentTime = currentTime;

    // move cursor
    this.chart.setCustomTime(currentTime * 1000, 'currentTime');
    // this.chart.setCurrentTime(currentTime * 1000);

    this.args.seeked?.(currentTime);
  };

  timeline = modifier((element: HTMLElement) => {
    this.chart = new Timeline(element, this.data, groups, {
      start: 0,
      min: 0,
      zoomMin: 0,
      orientation: 'top',
      snap: null,
      showCurrentTime: false,
      showMajorLabels: false,
      format: {
        minorLabels: (date: Date, scale: string /*, step*/) => {
          return Intl.DateTimeFormat('de', {
            dateStyle: undefined,
            hour: undefined,
            minute: '2-digit',
            second: '2-digit',
            ...(scale === 'millisecond'
              ? {
                  fractionalSecondDigits: 3
                }
              : {})
          }).format(date);
        }
      },
      ...(this.args.options ?? {})
    });

    this.chart.addCustomTime(0, 'currentTime');
    this.chart.setCustomTimeTitle('', 'currentTime');

    this.chart.on('click', (e) => {
      element.focus();

      if (e.what === 'background') {
        this.player.seekTo(dateToSecondsWithMilli(e.time as Date), true);
      }
    });

    this.args.setChartApi?.(this.chart, this.data);

    return () => {
      this.chart.destroy();
    };
  });

  handleKeyboard = (event: KeyboardEvent) => {
    if (!this.args.active) {
      return;
    }

    switch (event.key) {
      case ' ':
        this.player.toggle();
        event.preventDefault();
        event.stopPropagation();

        break;

      case 'ArrowRight':
        if (event.altKey) {
          this.player.seek(0.25);
        } else if (event.ctrlKey) {
          this.player.seek(1);
        } else if (event.shiftKey) {
          this.player.seek(10);
        } else {
          this.player.seek(0.1);
        }

        event.preventDefault();
        event.stopPropagation();

        break;

      case 'ArrowLeft':
        if (event.altKey) {
          this.player.seek(-0.25);
        } else if (event.ctrlKey) {
          this.player.seek(-1);
        } else if (event.shiftKey) {
          this.player.seek(-10);
        } else {
          this.player.seek(-0.1);
        }

        event.preventDefault();
        event.stopPropagation();

        break;
    }
  };

  <template>
    {{#if @playerApi}}
      {{this.setPlayerApi @playerApi}}
    {{else if @video}}
      <YoutubePlayer @url={{@video}} @controls={{true}} @setApi={{this.setPlayerApi}} />
    {{/if}}

    <div tabindex="0" class={{styles.timeline}} {{this.timeline}}></div>
  </template>
}
