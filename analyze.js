const fs = require('fs');
const data = JSON.parse(fs.readFileSync('assets/baseDatos/hojas_vida.json','utf-8'));
const vals = Object.entries(data).filter(([k,v]) => v.nivelEducacion);

// Por partido
const partidos = {};
vals.forEach(([dni, v]) => {
  const p = v.partido;
  if (!partidos[p]) partidos[p] = {total:0, doctores:0, maestros:0, conPosgrado:0, sinSentPenal:0, sinSentOblig:0};
  const pp = partidos[p];
  pp.total++;
  if (v.esDoctor) pp.doctores++;
  if (v.esMaestro) pp.maestros++;
  if (v.flagPosgrado === '1') pp.conPosgrado++;
  if (v.totalSentenciasPenales === 0) pp.sinSentPenal++;
  if (v.totalSentenciasObligaciones === 0) pp.sinSentOblig++;
});

const top = Object.entries(partidos).sort((a,b) => b[1].total - a[1].total).slice(0,12);
top.forEach(([p, d]) => {
  const pctPosgrado = Math.round(d.conPosgrado/d.total*100);
  const pctSinPenal = Math.round(d.sinSentPenal/d.total*100);
  console.log(p.substring(0,38).padEnd(38), 'n='+String(d.total).padStart(3), 'posgrado='+String(pctPosgrado)+'%', 'sinPenal='+String(pctSinPenal)+'%');
});

// Scoring integral de candidatos
const scored = vals.map(([dni, v]) => {
  let score = 0;
  if (v.esDoctor) score += 40;
  else if (v.esMaestro) score += 30;
  else if (v.flagPosgrado === '1') score += 20;
  else if (v.tieneUniversitaria) score += 10;
  else if (v.tieneTecnica) score += 5;
  if (v.totalSentenciasPenales === 0) score += 30;
  else score -= v.totalSentenciasPenales * 20;
  if (v.totalSentenciasObligaciones === 0) score += 20;
  else score -= v.totalSentenciasObligaciones * 10;
  if (v.renuncioA && v.renuncioA.length > 0) score -= 5;
  return { dni, nombre: v.nombre, partido: v.partido, nivelEdu: v.nivelEducacion, score,
    sentPenal: v.totalSentenciasPenales, sentOblig: v.totalSentenciasObligaciones };
}).sort((a,b) => b.score - a.score);

console.log('\nTop 10 candidatos por perfil integral:');
scored.slice(0,10).forEach(c => console.log(' Score', c.score, '|', c.nombre.substring(0,35), '|', c.partido.substring(0,30), '|', c.nivelEdu));
console.log('\nScore máximo posible: 90');
