clear;
signals;
fprintf('mark1_devtime: %d\n', size(mark1_devtime)(2));
fprintf('mark4_devtime: %d\n', size(mark4_devtime)(2));
fprintf('ladybug_devtime: %d\n', size(ladybug_devtime(~isnan(ladybug_devtime)))(2));
fprintf('multiplex_ladybug_mark4: %d\n', size(multiplex_ladybug_mark4)(2));

figure('visible','on');
subplot(2,2,1);
plot(1./mark4_devtime_s0_d, 'DisplayName', 'Mark4');
hold on;
plot(multiplex_ladybug_mark4(1:end-1), 1./diff(ladybug_devtime_ucycled_s0(multiplex_ladybug_index)), 'r+', 'DisplayName', 'Ladybug');
title(['multiplexed signals: ' num2str(size(multiplex_ladybug_index)(2))], 'FontSize', 14);
xlabel('count (#)');
ylabel('frequency (Hz)');
grid on;
legend show;

subplot(2,2,2);
plot((mark4_devtime_s0(multiplex_ladybug_mark4)-mark4_devtime_s0(multiplex_ladybug_mark4(1)))-
  (ladybug_devtime_ucycled_s0(multiplex_ladybug_index)- ladybug_devtime_ucycled_s0(multiplex_ladybug_index(1))))
title('signals clock comparison', 'FontSize', 14)
xlabel('count (#)');
ylabel('clocks difference (s)');
grid on;

subplot(2,2,3);
if exist ('tracks.csv', 'file') > 0 && exist ('leica_tracks.csv', 'file') > 0
  horus = csvread('tracks.csv');
  horus = horus(2:end,:);
  leica = dlmread('leica_tracks.csv', ';');
  leica = leica(2:end,:);

  %pkg load signal;
  %[val,idx] = max(xcorr(leica(:,4), horus(:,5)));
  shift = 0; %(length(leica(:,4)) - idx) * -1;

  plot(leica(:,4), 'DisplayName', ['Leica ' num2str(size(leica)(1)) ' [' num2str(size(nonzeros(leica(:,4)))(1)) ']'])
  hold on;
  plot([shift+1:shift+size(horus(:,5))(1)], horus(:,5), 'r+', 'DisplayName', ['Horus ' num2str(size(horus)(1)) ' [' num2str(size(nonzeros(horus(:,5)))(1)) ']'])
  title(['tracks comparison']); % [shift=' num2str(shift) ']'], 'FontSize', 14)
  ylabel('count (#)');
  xlabel('track (#)');
  grid on;
  legend show;
else
  plot(mark4_devtime_s0_d, 'DisplayName', 'mark4');
  hold on;
  plot((ladybug_devtime_ucycled_s0_d_peaks_mark4_offset(2):ladybug_devtime_ucycled_s0_d_peaks_mark4_offset(2)+ladybug_devtime_ucycled_s0_d_peaks_mark4_offset(3)),ladybug_devtime_ucycled_s0_d(ladybug_devtime_ucycled_s0_d_peaks_sig_offset(2):ladybug_devtime_ucycled_s0_d_peaks_sig_offset(2) + ladybug_devtime_ucycled_s0_d_peaks_sig_offset(3)), 'r+', 'DisplayName', 'ladybug');
  title('starting peak-peak correlation', 'FontSize', 14);
  xlabel('count (#)');
  ylabel('first derivative (s)');
  legend show;
endif

subplot(2,2,4);
m4 = [summary_hour_start_mark4 summary_hour_stop_mark4];
m1 = [summary_hour_start_mark1 summary_hour_stop_mark1];
lbg = [min(summary_hour_start_Ladybug_Grabber) max(summary_hour_stop_Ladybug_Grabber)];
tbox = [min(summary_hour_start_Triggerbox)  max(summary_hour_stop_Triggerbox)];
state = [min(summary_hour_start_SystemState)  max(summary_hour_stop_SystemState)];
nmea = [min(summary_hour_start_Serial_NMEA_Reader)  max(summary_hour_stop_Serial_NMEA_Reader)];
minimum = [m4(1);m1(1);lbg(1);tbox(1);state(1);nmea(1)];
maximum = [m4(end);m1(end);lbg(end);tbox(end);state(end);nmea(end)];

h = bar([minimum, maximum-minimum], "stacked", "BaseValue", min(minimum));
set(h(1), "visible", "off");
set(gca, "ylim", [min(minimum), max(maximum)+1]);
grid on;
set(gca,'xticklabel',{"Mark4","Mark1","Ladybug","Trigger","State","NMEA"})
ylabel("time (h)");
title("recorded time", 'FontSize', 14);
text(1, (m4(1) + m4(2)) / 2, num2str(size(mark4_devtime)(2)), 'horizontalalignment', 'center', 'FontSize', 12)
text(2, (m1(1) + m1(2)) / 2, num2str(size(mark1_devtime)(2)), 'horizontalalignment', 'center', 'FontSize', 12)
text(3, (lbg(1) + lbg(2)) / 2, num2str(size(ladybug_devtime(~isnan(ladybug_devtime)))(2)), 'horizontalalignment', 'center', 'FontSize', 12)

% print('horus_report.png','-dpng', '-S2560,1600');
