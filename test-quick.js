const axios = require('axios');

const BASE_URL = 'http://localhost:3000';
let accessToken = '';
let refreshToken = '';
let userId = '';
let roleId = '';
let permissionId = '';
let delegationId = '';
let taskId = '';

const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  blue: '\x1b[36m',
  yellow: '\x1b[33m',
  reset: '\x1b[0m'
};

const log = {
  success: (msg) => console.log(`${colors.green}✅ ${msg}${colors.reset}`),
  error: (msg) => console.log(`${colors.red}❌ ${msg}${colors.reset}`),
  info: (msg) => console.log(`${colors.blue}📌 ${msg}${colors.reset}`),
  test: (msg) => console.log(`\n${colors.yellow}🧪 ${msg}${colors.reset}`)
};

async function test(endpoint, method, data = null, token = null) {
  try {
    const config = {
      method,
      url: `${BASE_URL}${endpoint}`,
      headers: token ? { Authorization: `Bearer ${token}` } : {},
      data: data || undefined
    };
    const response = await axios(config);
    log.success(`${method} ${endpoint} - ${response.status}`);
    return response.data;
  } catch (error) {
    if (error.response) {
      log.error(`${method} ${endpoint} - ${error.response.status}: ${error.response.data?.error || error.message}`);
    } else {
      log.error(`${method} ${endpoint} - ${error.message}`);
    }
    return null;
  }
}

async function runTests() {
  console.log('\n========================================');
  console.log('🚀 TEST RÀPID T9 - 51 ENDPOINTS');
  console.log('========================================\n');

  // ==========================================
  // 1. AUTENTICACIÓ (7 proves)
  // ==========================================
  log.test('1. AUTENTICACIÓ (7 proves)');
  
  // 1.1 Register
  const registerData = { email: `test${Date.now()}@example.com`, password: 'Password123!', firstName: 'Test', lastName: 'User' };
  const register = await test('/api/auth/register', 'post', registerData);
  if (register?.data?.accessToken) accessToken = register.data.accessToken;
  if (register?.data?.refreshToken) refreshToken = register.data.refreshToken;
  
  // 1.2 Login
  const login = await test('/api/auth/login', 'post', { email: 'admin@system.com', password: 'Admin123!' });
  if (login?.data?.accessToken) {
    accessToken = login.data.accessToken;
    refreshToken = login.data.refreshToken;
    userId = login.data?.data?.user?.id;
  }
  
  // 1.3 Login incorrecte
  await test('/api/auth/login', 'post', { email: 'admin@system.com', password: 'wrongpassword' });
  
  // 1.4 Refresh token
  if (refreshToken) await test('/api/auth/refresh', 'post', { refreshToken });
  
  // 1.5 Forgot password
  await test('/api/auth/forgot-password', 'post', { email: 'admin@system.com' });
  
  // 1.6 Logout (després de les proves)
  
  // ==========================================
  // 2. USUARIS (5 proves)
  // ==========================================
  log.test('2. USUARIS (5 proves)');
  
  if (accessToken) {
    const users = await test('/api/users', 'get', null, accessToken);
    if (users?.data?.length > 0 && !userId) userId = users.data[0]._id;
    
    if (userId) {
      await test(`/api/users/${userId}`, 'get', null, accessToken);
      await test(`/api/users/${userId}/permissions`, 'get', null, accessToken);
      await test(`/api/users/${userId}`, 'put', { name: 'Test Updated' }, accessToken);
    }
  }
  
  // ==========================================
  // 3. ROLS (8 proves)
  // ==========================================
  log.test('3. ROLS (8 proves)');
  
  if (accessToken) {
    const roles = await test('/api/roles', 'get', null, accessToken);
    if (roles?.data?.length > 0) {
      roleId = roles.data[0]._id;
      await test(`/api/roles/${roleId}`, 'get', null, accessToken);
      await test(`/api/roles/${roleId}/hierarchy`, 'get', null, accessToken);
      await test(`/api/roles/${roleId}/permissions`, 'get', null, accessToken);
    }
    
    // Crear rol
    const newRole = await test('/api/roles', 'post', {
      name: `test_role_${Date.now()}`,
      level: 2,
      description: 'Rol de test'
    }, accessToken);
    if (newRole?.data?._id) roleId = newRole.data._id;
    
    // Actualitzar rol
    if (roleId) await test(`/api/roles/${roleId}`, 'put', { description: 'Rol actualitzat' }, accessToken);
    
    // Esborrar rol
    if (roleId && roleId !== roles?.data?.[0]?._id) await test(`/api/roles/${roleId}`, 'delete', null, accessToken);
  }
  
  // ==========================================
  // 4. PERMISOS (6 proves)
  // ==========================================
  log.test('4. PERMISOS (6 proves)');
  
  if (accessToken) {
    const permissions = await test('/api/permissions', 'get', null, accessToken);
    if (permissions?.data?.length > 0) {
      permissionId = permissions.data[0]._id;
      await test(`/api/permissions/${permissionId}`, 'get', null, accessToken);
    }
    
    // Crear permís
    const newPerm = await test('/api/permissions', 'post', {
      name: `test:perm_${Date.now()}`,
      description: 'Permís de test',
      category: 'test'
    }, accessToken);
    if (newPerm?.data?._id) permissionId = newPerm.data._id;
    
    // Actualitzar permís
    if (permissionId) await test(`/api/permissions/${permissionId}`, 'put', { description: 'Permís actualitzat' }, accessToken);
    
    // Esborrar permís
    if (permissionId) await test(`/api/permissions/${permissionId}`, 'delete', null, accessToken);
    
    // Error duplicat
    await test('/api/permissions', 'post', {
      name: 'tasks:read',
      description: 'Duplicat',
      category: 'tasks'
    }, accessToken);
  }
  
  // ==========================================
  // 5. DELEGACIÓ (6 proves)
  // ==========================================
  log.test('5. DELEGACIÓ DE PERMISOS (6 proves)');
  
  if (accessToken && userId) {
    const delegations = await test('/api/delegations', 'get', null, accessToken);
    if (delegations?.data?.length > 0) delegationId = delegations.data[0]._id;
    
    // Crear delegació
    const newDeleg = await test('/api/delegations', 'post', {
      toUserId: userId,
      permission: 'tasks:read',
      reason: 'Test delegació',
      daysValid: 5
    }, accessToken);
    if (newDeleg?.data?._id) delegationId = newDeleg.data._id;
    
    if (delegationId) {
      await test(`/api/delegations/${delegationId}`, 'get', null, accessToken);
      await test(`/api/delegations/user/${userId}`, 'get', null, accessToken);
      await test(`/api/delegations/${delegationId}`, 'delete', null, accessToken);
    }
    
    // Error: dies negatius
    await test('/api/delegations', 'post', {
      toUserId: userId,
      permission: 'tasks:read',
      reason: 'Test',
      daysValid: -1
    }, accessToken);
  }
  
  // ==========================================
  // 6. AUDITORIA (5 proves)
  // ==========================================
  log.test('6. AUDITORIA (5 proves)');
  
  if (accessToken) {
    await test('/api/audit/logs', 'get', null, accessToken);
    await test('/api/audit/logs?action=tasks:read', 'get', null, accessToken);
    if (userId) await test(`/api/audit/logs?userId=${userId}`, 'get', null, accessToken);
    await test('/api/audit/stats', 'get', null, accessToken);
    await test('/api/audit/export?format=csv', 'get', null, accessToken);
  }
  
  // ==========================================
  // 7. TASQUES (5 proves)
  // ==========================================
  log.test('7. TASQUES (5 proves)');
  
  if (accessToken) {
    // Crear tasca
    const task = await test('/api/tasks', 'post', {
      title: 'Tasca test',
      description: 'Descripció',
      status: 'pending',
      priority: 'high'
    }, accessToken);
    if (task?.data?.id) taskId = task.data.id;
    
    // Llistar tasques
    await test('/api/tasks?page=1&limit=10', 'get', null, accessToken);
    
    if (taskId) {
      await test(`/api/tasks/${taskId}`, 'get', null, accessToken);
      await test(`/api/tasks/${taskId}`, 'put', { title: 'Tasca actualitzada', status: 'in_progress' }, accessToken);
      await test(`/api/tasks/${taskId}`, 'delete', null, accessToken);
    }
  }
  
  // ==========================================
  // 8. SEGURETAT (5 proves)
  // ==========================================
  log.test('8. SEGURETAT (5 proves)');
  
  // Sense token
  await test('/api/tasks', 'get');
  
  // Token invàlid
  await test('/api/tasks', 'get', null, 'token_invalid_123');
  
  // Accés sense permís (usuari normal intenta crear rol)
  // Primer registrem un usuari normal
  const normalUser = await test('/api/auth/register', 'post', {
    email: `normal${Date.now()}@example.com`,
    password: 'Password123!',
    firstName: 'Normal',
    lastName: 'User'
  });
  if (normalUser?.data?.accessToken) {
    await test('/api/roles', 'post', { name: 'test_rol', level: 1, description: 'Test' }, normalUser.data.accessToken);
  }
  
  // Logout final
  if (accessToken && refreshToken) {
    await test('/api/auth/logout', 'post', { refreshToken }, accessToken);
  }
  
  // ==========================================
  // 9. ERRORS (4 proves)
  // ==========================================
  log.test('9. ERRORS (4 proves)');
  
  // Email invàlid
  await test('/api/auth/register', 'post', {
    email: 'email_invalid',
    password: 'Password123!',
    firstName: 'Test',
    lastName: 'User'
  });
  
  // Contrasenya feble
  await test('/api/auth/register', 'post', {
    email: `test${Date.now()}@example.com`,
    password: '123',
    firstName: 'Test',
    lastName: 'User'
  });
  
  // Email duplicat
  await test('/api/auth/register', 'post', {
    email: 'admin@system.com',
    password: 'Password123!',
    firstName: 'Test',
    lastName: 'User'
  });
  
  // Recurs no trobat
  await test('/api/tasks/id_inexistent', 'get', null, accessToken);
  
  // ==========================================
  // RESULTAT FINAL
  // ==========================================
  console.log('\n========================================');
  console.log('🎉 TEST COMPLETATS!');
  console.log('========================================');
  console.log('📊 Revisa els resultats:');
  console.log('   ✅ Verd = Endpoint funciona');
  console.log('   ❌ Vermell = Endpoint amb error');
  console.log('========================================\n');
}

runTests().catch(console.error);
