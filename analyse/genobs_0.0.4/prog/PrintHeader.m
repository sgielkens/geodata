function PrintHeader(proj, dim, mesg)
  % Message to start listing with heading
  switch dim
    case 1
      dimstr = '1D';
    case 2
      dimstr = '2D';
    case 3
      dimstr = '3D';
    otherwise
      dimstr = 'Could not be determined';
  end % switch
  Mesg={['Programme:     genobs'];
        ['Version:       ' genobs_version()];
        ['Author:        Hiddo Velsink'];
        ['Date and time: ' datestr(now)];
        ['Project:       ' proj];
        ['Dimension:     ' dimstr];
        [''];
        [mesg]};
  PrintMsg(Mesg)
end

