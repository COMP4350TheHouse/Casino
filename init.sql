grant create, alter, drop, insert, update, delete, select, references
    on casino_development.*
    to 'casino'@'%';

grant create, alter, drop, insert, update, delete, select, references
    on casino_test.*
    to 'casino'@'%';

grant create, alter, drop, insert, update, delete, select, references
    on casino_production.*
    to 'casino'@'%';

grant create, alter, drop, insert, update, delete, select, references
    on casino_production_cache.*
    to 'casino'@'%';

grant create, alter, drop, insert, update, delete, select, references
    on casino_production_queue.*
    to 'casino'@'%';

grant create, alter, drop, insert, update, delete, select, references
    on casino_production_cable.*
    to 'casino'@'%';
