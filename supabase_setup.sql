-- ============================================
-- CUIDANDO PATITAS — Script de configuración de Supabase
-- Corre esto en el SQL Editor de tu proyecto de Supabase
-- ============================================

-- 1) Extensión necesaria para generar IDs únicos
create extension if not exists "pgcrypto";

-- 2) Tabla principal de mascotas en adopción
create table if not exists mascotas (
  id uuid primary key default gen_random_uuid(),
  creado_en timestamp with time zone default now(),

  -- Datos de quien entrega la mascota
  nombres_dueno text not null,
  apellidos_dueno text not null,
  direccion text not null,
  telefono text not null,

  -- Tipo de animal
  tipo_animal text not null check (tipo_animal in ('Perro', 'Gato', 'Otro')),
  tipo_otro text, -- solo se llena si tipo_animal = 'Otro'

  -- Datos de la mascota
  nombre_mascota text, -- opcional
  raza text not null,
  edad_valor integer not null,
  edad_unidad text not null check (edad_unidad in ('Meses', 'Años')),
  sexo text not null check (sexo in ('Macho', 'Hembra')),
  esterilizado boolean not null default false,
  tamano text not null check (tamano in ('Pequeño', 'Mediano', 'Grande')),
  foto_url text, -- URL pública de la foto en Supabase Storage

  -- Estado de la publicación (útil para marcar cuando ya fue adoptada)
  estado text not null default 'Disponible' check (estado in ('Disponible', 'Adoptado'))
);

-- 3) Activar seguridad a nivel de fila (RLS)
alter table mascotas enable row level security;

-- 4) Política: cualquiera puede REGISTRAR una mascota (insertar)
create policy "Cualquiera puede registrar una mascota"
  on mascotas for insert
  to anon
  with check (true);

-- 5) Política: cualquiera puede VER las mascotas disponibles
create policy "Cualquiera puede ver las mascotas"
  on mascotas for select
  to anon
  using (true);

-- ============================================
-- POLÍTICAS PARA EL STORAGE (FOTOS)
-- Antes de correr esto, crea manualmente el bucket "fotos-mascotas"
-- desde Storage → New bucket → marca "Public bucket"
-- ============================================

-- 6) Permitir que cualquiera SUBA fotos al bucket
create policy "Cualquiera puede subir fotos de mascotas"
  on storage.objects for insert
  to anon
  with check (bucket_id = 'fotos-mascotas');

-- 7) Permitir que cualquiera VEA las fotos
create policy "Cualquiera puede ver fotos de mascotas"
  on storage.objects for select
  to anon
  using (bucket_id = 'fotos-mascotas');
