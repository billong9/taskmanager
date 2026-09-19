import { apiClient } from './client'
import type { AuthUser } from '../types/model'

export interface RegisterPayload {
  fullName: string
  email: string
  password: string
}

export interface LoginPayload {
  email: string
  password: string
}

export async function registerUser(payload: RegisterPayload): Promise<AuthUser> {
  const { data } = await apiClient.post('/auth/register', payload)
  return data
}

export async function loginUser(payload: LoginPayload): Promise<AuthUser> {
  const { data } = await apiClient.post('/auth/login', payload)
  return data
}
