# Lees MOVE3 bestanden in om invoer voor vereffening te bepalen

# Input
# - naam MOVE3 project
# - pad naar MOVE3 projectbestanden
# - vast punt, d.w.z. station dat basispunt vormt

# Output
# - vector met waarnemingen
# - vector met afstanden tussen meetpunten
# - aantal voorwaarden


function [ station, waarneming, punt_van, punt_naar, afstand, aantal_parameters, aantal_voorwaarden, hoogte_vast_punt ] = lees_invoer(naam_project, pad_project, vast_punt)

  file_tco = [ pad_project naam_project '.tco' ] ;
  file_obs = [ pad_project naam_project '.Obs' ] ;

  [station hoogte] = textread (file_tco,
    "%s %*f %*f %f",
     'headerlines' , 6, 'commentstyle', '$'
  ) ;
  aantal_stations=size(station,1) ;

  hoogte_vast_punt = 'x' ;

  for i=1:aantal_stations
    if (strcmp(station(i,1), 'A'))
      hoogte_vast_punt = hoogte(i) ;
      break
    endif
  end

  if (hoogte_vast_punt == 'x')
    uitvoer=['!!! NOK !!!'] ;
    disp(uitvoer)
    return
  end


  [punt_van punt_naar waarneming afstand] = textread(file_obs,
    "%*s %s %s %f %f %*f %*f %*f",
    'headerlines', 7, 'commentstyle', '$'
  ) ;

  aantal_waarnemingen=size(waarneming,1) ;
  aantal_afstanden=size(afstand,1) ;

  if (aantal_waarnemingen != aantal_afstanden)
    uitvoer=['!!! NOK !!!'] ;
    disp(uitvoer)
    return
  end

  aantal_parameters = aantal_stations - 1 ;
  aantal_voorwaarden = aantal_waarnemingen - aantal_parameters ;

end
