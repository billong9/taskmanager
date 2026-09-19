import { useCallback, useEffect, useState } from 'react'
import { useAuth } from '../context/AuthContext'
import { createTask, deleteTask, fetchTasks, updateTask } from '../api/tasks'
import { extractErrorMessage } from '../api/client'
import type { Task, TaskInput, TaskStatus } from '../types/model'
import TaskCard from '../components/TaskCard'
import TaskModal from '../components/TaskModal'
import Toast, { type ToastType } from '../components/Toast'

export default function Tasks() {
  const { user, logout } = useAuth()

  const [tasks, setTasks] = useState<Task[]>([])
  const [loading, setLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState<TaskStatus | ''>('')
  const [search, setSearch] = useState('')

  const [modalOpen, setModalOpen] = useState(false)
  const [editingTask, setEditingTask] = useState<Task | null>(null)

  const [toast, setToast] = useState<{ message: string; type: ToastType } | null>(null)

  const loadTasks = useCallback(async () => {
    setLoading(true)
    try {
      const data = await fetchTasks({ status: statusFilter, search })
      setTasks(data)
    } catch (err) {
      setToast({ message: extractErrorMessage(err), type: 'error' })
    } finally {
      setLoading(false)
    }
  }, [statusFilter, search])

  useEffect(() => {
    const timeout = setTimeout(loadTasks, 300) // debounce recherche
    return () => clearTimeout(timeout)
  }, [loadTasks])

  function openCreateModal() {
    setEditingTask(null)
    setModalOpen(true)
  }

  function openEditModal(task: Task) {
    setEditingTask(task)
    setModalOpen(true)
  }

  async function handleSave(input: TaskInput) {
    try {
      if (editingTask) {
        await updateTask(editingTask.id, input)
        setToast({ message: 'Tâche mise à jour avec succès', type: 'success' })
      } else {
        await createTask(input)
        setToast({ message: 'Tâche créée avec succès', type: 'success' })
      }
      setModalOpen(false)
      loadTasks()
    } catch (err) {
      setToast({ message: extractErrorMessage(err), type: 'error' })
    }
  }

  async function handleDelete(task: Task) {
    if (!confirm(`Supprimer la tâche "${task.title}" ?`)) return
    try {
      await deleteTask(task.id)
      setToast({ message: 'Tâche supprimée', type: 'success' })
      loadTasks()
    } catch (err) {
      setToast({ message: extractErrorMessage(err), type: 'error' })
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="border-b border-gray-200 bg-white">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-4">
          <div>
            <h1 className="text-lg font-bold text-gray-900">Task Manager</h1>
            <p className="text-xs text-gray-500">Connecté en tant que {user?.fullName}</p>
          </div>
          <button
            onClick={logout}
            className="rounded-lg border border-gray-300 px-3 py-1.5 text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            Déconnexion
          </button>
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-4 py-6">
        <div className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div className="flex flex-1 flex-col gap-3 sm:flex-row">
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Rechercher une tâche..."
              className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500 sm:max-w-xs"
            />
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as TaskStatus | '')}
              className="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            >
              <option value="">Tous les statuts</option>
              <option value="TODO">À faire</option>
              <option value="IN_PROGRESS">En cours</option>
              <option value="DONE">Terminée</option>
            </select>
          </div>

          <button
            onClick={openCreateModal}
            className="rounded-lg bg-brand-600 px-4 py-2 text-sm font-medium text-white hover:bg-brand-700"
          >
            + Nouvelle tâche
          </button>
        </div>

        {loading ? (
          <p className="text-center text-sm text-gray-500">Chargement...</p>
        ) : tasks.length === 0 ? (
          <div className="rounded-xl border border-dashed border-gray-300 bg-white p-10 text-center">
            <p className="text-sm text-gray-500">Aucune tâche trouvée.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {tasks.map((task) => (
              <TaskCard key={task.id} task={task} onEdit={openEditModal} onDelete={handleDelete} />
            ))}
          </div>
        )}
      </main>

      {modalOpen && (
        <TaskModal task={editingTask} onClose={() => setModalOpen(false)} onSave={handleSave} />
      )}

      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
    </div>
  )
}
