# Lees MOVE3 bestanden in om invoer voor vereffening te bepalen

# Input
# - naam MOVE3 project
# - pad naar MOVE3 projectbestanden
# - vast punt, d.w.z. station dat basispunt vormt

# Output
# - vector met waarnemingen
# - vector met afstanden tussen meetpunten
# - aantal voorwaarden


function [Amatrix, a0] = A_vergelijking(station, punt_van, punt_naar, vast_punt, hoogte_vast_punt)

  aantal_waarnemingen=size(punt_van,1) ;
  aantal_stations=size(station,1) ;
  aantal_parameters = aantal_stations - 1 ;

  a0=zeros(aantal_waarnemingen, 1) ;
  Amatrix=zeros(aantal_waarnemingen, aantal_parameters) ;

  station_index = struct() ;
  for i=1:aantal_stations
    station_naam = char(station(i)) ;
    if (station_naam == vast_punt)
      continue
    end
    station_index.(station_naam) = i - 1 ;
  end

  for i=1:aantal_waarnemingen

    if (strcmp(punt_van(i,1), vast_punt))
      punt_van(i,1) ;
      a0(i) = [ -hoogte_vast_punt ] ;

      station_naam=char(punt_naar(i,1)) ;
      kolom = station_index.(station_naam) ;
      Amatrix(i, kolom) = 1 ;
    elseif (strcmp(punt_naar(i,1), vast_punt))
      a0(i) = [ hoogte_vast_punt ] ;

      station_naam=char(punt_van(i,1)) ;
      kolom = station_index.(station_naam) ;
      Amatrix(i, kolom) = -1 ;
    else
      station_naam=char(punt_van(i,1)) ;
      kolom = station_index.(station_naam) ;
      Amatrix(i, kolom) = -1 ;

      station_naam=char(punt_naar(i,1)) ;
      kolom = station_index.(station_naam) ;
      Amatrix(i, kolom) = 1 ;
    end

  end

end
