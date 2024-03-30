-- Test BUILD_EDGE_SERVER e ADD_EDGE_SERVER
set @_check = 0;
CALL filmsphere.BUILD_EDGE_SERVER(@_check);
SELECT @_check;