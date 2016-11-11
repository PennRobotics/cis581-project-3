function [match] = feat_match(descs1, descs2)
% descs1 is a 64 x n1 matrix of double values
% descs2 is a 64 x n2 matrix of double values
% match is n1 x 1 vector of integers where m(i) points to the index of the
% descriptor in p2 that matches with the descriptor p1(:, i).
% If no match is found, m(i) = -1

MATCH_THRES = 0.83;

N = size(descs1, 2);
match = -1 + zeros(N, 1);

for i = 1 : N
  descsDelta = repmat(descs1(:, i), [1, N]) - descs2;
  descsSSD = sum(descsDelta .^ 2);
  [descsSSD1, idxMin] = min(descsSSD);
  descsSSD(idxMin) = [];
  descsSSD2 = min(descsSSD);
  if descsSSD1 / descsSSD2 <= MATCH_THRES, match(i) = idxMin; end;
end
end
