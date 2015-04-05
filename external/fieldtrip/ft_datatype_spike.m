function spike = ft_datatype_spike(spike, varargin)

% FT_DATATYPE_SPIKE describes the FieldTrip MATLAB structure for spike data
%
% Spike data is obtained using FT_READ_SPIKE to read files from a Plexon,
% Neuralynx or other animal electrophysiology data acquisition system. It
% is characterised as a sparse point-process, i.e. each neuronal firing is
% only represented as the time at which the firing happened. Optionally,
% the spike waveform can also be represented. Using this waveform, the
% neuronal firing events can be sorted into their single units.
%
% A required characteristic of the SPIKE structure is a cell-array with the
% label of the (single or multi) units.
%
%         label: {'unit1'  'unit2'  'unit3'}
%
% The fields of the SPIKE structure that contain the specific information
% per spike depends on the available information. A relevant distinction
% can be made between the representation of raw spikes that are not related
% to the temporal strucutre of the experimental design (i.e trials), and
% the data representation in which the spikes are related to the trial.
%
% For a continuous recording the SPIKE structure must contain a cell-array
% with the raw timestamps as recorded by the hardware system. As example,
% the original content of the .timestamp field can be
%
%         timestamp:  {[1x993 uint64]  [1x423 uint64]  [1x3424 uint64]}
%
% An optional field that is typically obtained from the raw recording
% contains the waveforms for every unit and label as a cell-array. For
% example, the content of this field may be
%
%         waveform:   {[32x993 double] [32x423 double] [32x3224 double]}
%
% If the data has been organised to reflect the temporal structure of the
% experiment (i.e. the trials), the SPIKE structure should contain a
% cell-array with the spike times relative to an experimental trigger. The
% FT_SPIKE_REDEFINETRIAL function can be used to reorganise the SPIKE
% structure such that the spike times are expressed relative to a trigger
% instead of relative to the acquisition devices internal timestamp clock.
% The time field then contains only those spikes that ocurred within one of
% the trials . The spike times are now expressed on seconds relative to the
% trigger.
%
%         time:       {[1x504 double] [1x50 double] [1x101 double]}
%
% In addition, for every spike we register in which trial the spike was
% recorded:
%
%         trial:      {[1x504 double] [1x50 double] [1x101 double]}
%
% To fully reconstruct the structure of the spike-train, it is required
% that the exact start- and end-point of the trial (in seconds) is
% represented. This is specified in a nTrials x 2 matrix.
%
%         trialtime:  [100x2 double]
%
% As an example, FT_SPIKE_REDEFINETRIALS could result in the following
% SPIKE structure that represents the spikes of three units that were
% observed in 100 trials:
%
%         label:      {'unit1'  'unit2'  'unit3'}
%         timestamp:  {[1x504 double] [1x50 double] [1x101 double]}
%         time:       {[1x504 double] [1x50 double] [1x101 double]}
%         trial:      {[1x504 double] [1x50 double] [1x101 double]}
%         trialtime:  [100x2 double]
%         waveform:   {[32x504 double] [32x50 double] [32x101 double]}
%         cfg
%
% For analysing the relation between the spikes and the local field
% potential (e.g. phase-locking), the SPIKE structure can have additional
% fields such as fourierspctrm, lfplabel, freq and fourierspctrmdimord.
%
% For example, from the structure above we may obtain
%
%         label:          {'unit1'  'unit2'  'unit3'}
%         timestamp:      {[1x504 double] [1x50 double] [1x101 double]}
%         time:           {[1x504 double] [1x50 double] [1x101 double]}
%         trial:          {[1x504 double] [1x50 double] [1x101 double]}
%         trialtime:      [100x2 double]
%         waveform:       {[32x504 double] [32x50 double] [32x101 double]}
%         fourierspctrm:  {504x2x20, 50x2x20, 101x2x20}
%         fourierspctrmdimord: '{chan}_spike_lfplabel_freq'
%         lfplabel:       {'lfpchan1', 'lfpchan2'}
%         freq:           [1x20 double]
%         cfg
%
% Required fields:
%   - the combination label and timestamp, or
%   - the combination label, time, trial and trialtime
%
% Optional fields:
%   - waveform
%   - fourierspctrm, fourierspctrmdimord, freq, lfplabel  (these are extra outputs from FT_SPIKETRIGGEREDSPECTRUM and FT_SPIKE_TRIGGEREDSPECTRUM)
%   - hdr
%   - cfg
%
% Deprecated fields:
%   - <unknown>
%
% Obsoleted fields:
%   - <unknown>
%
% Revision history:
%
% (2011/latest) Defined a consistent spike data representation that can
% also contain the Fourier spectrum and other fields. Use the xxxdimord
% to indicate the dimensions of the field.
%
% (2010) Introduced the time and the trialtime fields.
%
% (2007) Introduced the spike data representation.
%
% See also FT_DATATYPE, FT_DATATYPE_RAW, FT_DATATYPE_FREQ, FT_DATATYPE_TIMELOCK

% Copyright (C) 2011, Robert Oostenveld & Martin Vinck
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: ft_datatype_spike.m 5005 2011-12-10 16:41:30Z marvin $


% get the optional input arguments, which should be specified as key-value pairs
version = ft_getopt(varargin, 'version', 'latest');

if strcmp(version, 'latest')
  version = '2011';
end

switch version
  case '2011'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if isfield(spike,'origtrial') && isfield(spike,'origtime')
      warning('The spike datatype format you are using is depreciated. Converting to newer spike format');
      spike.trial = {spike.origtrial};
      spike       = rmfield(spike,'origtrial');      
      spike.time  = {spike.origtime};
      spike       = rmfield(spike,'origtime');
      if ~isa(spike.fourierspctrm, 'cell')
        spike.fourierspctrm = {spike.fourierspctrm};
      end
      if ~isfield(spike, 'trialtime')
        % determine from the data itself
        warning('Reconstructing the field trialtime from spike.origtime and spike.origtrial');
        tmax  = nanmax(spike.trial{1});
        tsmin = nanmin(spike.time{1});
        tsmax = nanmax(spike.time{1});
        spike.trialtime = [tsmin*ones(tmax,1) tsmax*ones(tmax,1)];
      end
      spike.lfplabel = spike.label; % in the old format, these were the lfp channels
      spike.label    = {'unit1'};
      spike.fourierspctrmdimord = '{chan}_spike_lfplabel_freq';
    end
    
  otherwise
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    error('unsupported version "%s" for spike datatype', version);
end


