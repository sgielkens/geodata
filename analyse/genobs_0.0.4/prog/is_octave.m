function r = is_octave ()
%% subfunction that checks if we are in octave
%% use in programme a line like:
%%    if (is_octave) 
%%        warning('off', 'Octave:possible-matlab-short-circuit-operator');
%%    end

    persistent x;
    if (isempty (x))
      x = exist ('OCTAVE_VERSION', 'builtin');
    end
    r = x;
end
