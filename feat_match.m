% TODO(brwr): feat_match.m
function [match] = feat_match(descs1, descs2)
% descs1 is a 64 x n1 matrix of double values
% descs2 is a 64 x n2 matrix of double values
% match is n1 x 1 vector of integers where m(i) points to the index of the
% descriptor in p2 that matches with the descriptor p1(:, i).
% If no match is found, m(i) = -1

match = -1 + zeros(size(descs1, 2), 1);
end
