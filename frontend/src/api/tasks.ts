import { apiClient } from './client'
import type { Task, TaskInput, TaskStatus } from '../types/model'

export interface TaskFilters {
  status?: TaskStatus | ''
  search?: string
}

export async function fetchTasks(filters: TaskFilters = {}): Promise<Task[]> {
  const params: Record<string, string> = {}
  if (filters.status) params.status = filters.status
  if (filters.search) params.search = filters.search

  const { data } = await apiClient.get('/tasks', { params })
  return data
}

export async function createTask(input: TaskInput): Promise<Task> {
  const { data } = await apiClient.post('/tasks', input)
  return data
}

export async function updateTask(id: number, input: TaskInput): Promise<Task> {
  const { data } = await apiClient.put(`/tasks/${id}`, input)
  return data
}

export async function deleteTask(id: number): Promise<void> {
  await apiClient.delete(`/tasks/${id}`)
}
