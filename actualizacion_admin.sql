-- ============================================
-- CUIDANDO PATITAS — Actualización: moderación + panel admin
-- Corre esto en el SQL Editor de Supabase (proyecto ya existente)
-- ============================================

-- 1) Las nuevas publicaciones entran como "Pendiente" en vez de "Disponible"
alter table mascotas alter column estado set default 'Pendiente';

-- 2) Quitamos las políticas viejas que dejaban ver TODO con la API key pública
drop policy if exists "Cualquiera puede ver las mascotas" on mascotas;
drop policy if exists "Cualquiera puede registrar una mascota" on mascotas;

-- 3) El público solo puede INSERTAR, y siempre como "Pendiente"
--    (evita que alguien inserte directamente como "Disponible" saltándose la moderación)
create policy "El público puede registrar una mascota como pendiente"
  on mascotas for insert
  to anon
  with check (estado = 'Pendiente');

-- 4) El público solo puede VER mascotas ya aprobadas ("Disponible")
create policy "El público solo ve mascotas disponibles"
  on mascotas for select
  to anon
  using (estado = 'Disponible');

-- 5) Un administrador con sesión iniciada (authenticated) puede ver TODO,
--    incluyendo pendientes y adoptadas
create policy "El admin ve todas las mascotas"
  on mascotas for select
  to authenticated
  using (true);

-- 6) El admin puede actualizar (aprobar, marcar como adoptado)
create policy "El admin puede actualizar mascotas"
  on mascotas for update
  to authenticated
  using (true)
  with check (true);

-- 7) El admin puede eliminar publicaciones
create policy "El admin puede eliminar mascotas"
  on mascotas for delete
  to authenticated
  using (true);

-- ============================================
-- CREAR EL USUARIO ADMINISTRADOR
-- ============================================
-- Esto NO se hace por SQL. Ve a:
--   Authentication → Users → Add user (en el dashboard de Supabase)
-- Crea un usuario con tu correo y una contraseña segura.
-- Con ese correo y contraseña iniciarás sesión en admin.html
