function obs = RemovePoints(obs, PointsToBeRemoved)
  n = size(PointsToBeRemoved, 1);
  for i=n:-1:1
      ind = PointsToBeRemoved(i);
      obs{1,1}(ind,:) = [];
      obs{1,2}(ind,:) = [];
  end
end