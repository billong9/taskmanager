export type TaskStatus = 'TODO' | 'IN_PROGRESS' | 'DONE'

export interface Task {
  id: number
  title: string
  description: string | null
  status: TaskStatus
  createdAt: string
  updatedAt: string
}

export interface TaskInput {
  title: string
  description: string
  status: TaskStatus
}

export interface AuthUser {
  userId: number
  fullName: string
  email: string
  token: string
}

export interface ApiError {
  timestamp: string
  status: number
  message: string
  path: string
}
