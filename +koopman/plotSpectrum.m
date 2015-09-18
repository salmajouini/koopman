function [hout, hbout] = plotSpectrum( varargin )
%PLOTSPECTRUM Plot Koopman spectrum.
%
% PLOTSPECTRUM( SPECTRUM )
%
%    Scatter plot of the complex-valued spectrum. Decay rate is placed on
%    the horizontal axis, oscillation frequency on the vertical axis.
%
% PLOTSPECTRUM( SPECTRUM, AMPLITUDES )
%
%    As before, but provide complex amplitudes. Absolute values of amplitudes are
%    translated to sizes of markers, angles of amplitudes to colors of
%    markers.
%
% PLOTSPECTRUM( ..., NORMALIZE )
%
%    Sizes of markers are normalized so that the largest marker is of size
%    25.
%
% HOUT = PLOTSPECTRUM(...)
% [HOUT, HBOUT] = PLOTSPECTRUM(...)
%
%   Return the Scatter object handle (H) generated by the plot and colorbar
%   handle (HB).

% Copyright 2015 under BSD license (see LICENSE file).

% Parse input arguments
parser = inputParser;
parser.addRequired('spectrum', @isvector );
parser.addOptional('amplitudes', [], @isvector );
parser.addOptional('normalize', true, @(x)isscalar(x) && islogical(x) );
parser.parse( varargin{:} );

% Extract decay rates/frequencies
Rates = real(parser.Results.spectrum);
Freq = imag(parser.Results.spectrum);

Sizes = [];
Phases = [];
% If amplitudes are given, use them to determine size and color
if ~isempty(parser.Results.amplitudes)
  Amps = parser.Results.amplitudes;
  validateattributes(Amps,{'numeric'},{'vector','numel', ...
                      numel(parser.Results.spectrum) } );

  % determine sizes of markers using absolute value of amplitudes
  Sizes = abs(Amps);
  if (parser.Results.normalize)
    Sizes = Sizes/max(Sizes)*50;
  end
  % minimum size has to be positive
  Sizes=1+Sizes;

  % determine colors of markers based on phases of amplitudes
  areAmpsReal = all(isreal(Amps) & Amps > 0);
  if ~areAmpsReal
    Phases = angle(Amps)/pi;
  end
end

if isempty(Phases)
  % empty phases signal monochrome plotting
  h = scatter( Rates, Freq, Sizes, 'filled' );
else
  % otherwise color is automatically assigned using hsv scheme
  h = scatter( Rates, Freq, Sizes, Phases, 'filled' );
  colormap(hsv);
  hb = colorbar('Location','South');
  hb.Position(4) = hb.Position(4)/4;
  hb.Label.String = 'Phase/\pi';
end

xlabel('Decay Rate');
ylabel('Frequency');

%%
% Assign outputs if requested
if nargout >= 1
  hout = h;
end
if nargout >= 2 && exist('hb','var')
  hbout = hb;
end
