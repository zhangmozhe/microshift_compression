% COMPRESSION_HDL_LOWPOWER_SCRIPT   Generate static library
%  compression_hdl_lowpower from compression_hdl_lowpower.
%
% Script generated from project 'compression_hdl_lowpower.prj' on 11-Mar-2020.
%
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.EmbeddedCodeConfig'.
cfg = coder.config('lib', 'ecoder', true);
cfg.GenerateCodeMetricsReport = true;
cfg.GenerateReport = true;
cfg.GenCodeOnly = true;

%% Define argument types for entry-point 'compression_hdl_lowpower'.
ARGS = cell(1, 1);
ARGS{1} = cell(7, 1);
ARGS{1}{1} = coder.typeof(uint8(0));
ARGS{1}{2} = coder.typeof(false);
ARGS{1}{3} = coder.typeof(false);
ARGS{1}{4} = coder.typeof(false);
ARGS{1}{5} = coder.typeof(false);
ARGS{1}{6} = coder.typeof(false);
ARGS{1}{7} = coder.typeof(fi(0, numerictype(0, 2, 0)));

%% Invoke MATLAB Coder.
codegen -config cfg compression_hdl_lowpower -args ARGS{1}
