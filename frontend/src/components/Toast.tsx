import { useEffect } from 'react'

export type ToastType = 'success' | 'error'

interface ToastProps {
  message: string
  type: ToastType
  onClose: () => void
}

export default function Toast({ message, type, onClose }: ToastProps) {
  useEffect(() => {
    const timer = setTimeout(onClose, 4000)
    return () => clearTimeout(timer)
  }, [onClose])

  const styles =
    type === 'success'
      ? 'bg-green-50 text-green-800 border-green-300'
      : 'bg-red-50 text-red-800 border-red-300'

  return (
    <div
      role="alert"
      className={`fixed top-4 right-4 z-50 max-w-sm rounded-lg border px-4 py-3 shadow-lg ${styles}`}
    >
      <div className="flex items-start justify-between gap-3">
        <p className="text-sm font-medium">{message}</p>
        <button onClick={onClose} className="text-lg leading-none opacity-60 hover:opacity-100">
          &times;
        </button>
      </div>
    </div>
  )
}
