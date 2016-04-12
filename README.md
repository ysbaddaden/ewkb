# Geos

Experimental [Well-Known Text](https://en.wikipedia.org/wiki/Well-known_text)
parser for the Crystal language, compatible with the OGC WKB, PostGIS EWKB and
SQL-MM part 3 GIS standards. It's primary goal is to be compatible with spatial
databases like PostGIS or SpatiaLite (among others).


## Status

Please note that I consider this Shard as a toy to learn about GIS and how to
handle binary protocols in Crystal.

If you like it and would like to maintain it, please contact me!


## Progress

- OGC WKB/WKT:
  - [x] WKB parser
  - [ ] WKT parser
  - [ ] geometries (WIP)
  - [ ] as text (WIP)
  - [ ] as binary

- PostGIS EWKB/EWKT:
  - [x] EWKB parser
  - [ ] EWKT parser
  - [ ] geometries (WIP)
  - [ ] as text (WIP)
  - [ ] as binary

- SQL-MM part 3:
  - [ ] binary parser (WIP)
  - [ ] text parser (WIP)
  - [ ] geometries (WIP)
  - [ ] as text (WIP)
  - [ ] as binary


## License

Distributed under the MIT License.


## Authors

- Julien Portalier <julien@portalier.com>
