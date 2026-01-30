'use client'

import { useState } from 'react'
import { createClient } from '@/utils/supabase/client'
import { useRouter } from 'next/navigation'
import { Loader2, Eye, EyeOff, Mail, Lock, Chrome, Apple, ChevronRight } from 'lucide-react'

export default function LoginPage() {
    const [email, setEmail] = useState('alainkwishima@gmail.com')
    const [password, setPassword] = useState('mukabareke')
    const [showPassword, setShowPassword] = useState(false)
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)
    const router = useRouter()
    const supabase = createClient()

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault()
        setLoading(true)
        setError(null)

        const { error } = await supabase.auth.signInWithPassword({
            email,
            password,
        })

        if (error) {
            setError(error.message)
            setLoading(false)
        } else {
            router.push('/')
            router.refresh()
        }
    }

    return (
        <div className="min-h-screen flex items-center justify-center p-4 lg:p-8 text-gray-800 dark:text-gray-200 transition-colors duration-300 font-inter">
            <div className="w-full max-w-[1400px] h-full lg:h-[90vh] bg-white dark:bg-surface-dark rounded-3xl shadow-strong overflow-hidden flex flex-col lg:flex-row border border-gray-100 dark:border-gray-700 relative">
                {/* Left Side: Login Form */}
                <div className="w-full lg:w-1/2 p-8 lg:p-12 xl:p-16 flex flex-col justify-between overflow-y-auto relative z-10 bg-white dark:bg-surface-dark no-scrollbar">
                    <div>
                        <div className="flex items-center gap-2 mb-8">
                            <div className="text-primary">
                                <svg fill="currentColor" height="32" viewBox="0 0 24 24" width="32" xmlns="http://www.w3.org/2000/svg">
                                    <path d="M12 2L4 7V17L12 22L20 17V7L12 2ZM12 4.5L17.5 8V16L12 19.5L6.5 16V8L12 4.5Z" fill="currentColor" fillRule="evenodd" opacity="0.2"></path>
                                    <path d="M12 6L7 9V15L12 18L17 15V9L12 6Z" fill="currentColor"></path>
                                </svg>
                            </div>
                            <span className="text-xl font-bold tracking-tight text-gray-900 dark:text-white">ClinicBooking</span>
                        </div>

                        <div className="max-w-md mx-auto w-full">
                            <div className="text-center mb-10">
                                <h1 className="text-3xl lg:text-4xl font-bold text-gray-900 dark:text-white mb-3">Welcome Back</h1>
                                <p className="text-gray-500 dark:text-gray-400">Enter your email and password to access the admin portal.</p>
                            </div>

                            <form onSubmit={handleLogin} className="space-y-5">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1" htmlFor="email">Email</label>
                                    <div className="relative">
                                        <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 h-5 w-5" />
                                        <input
                                            className="w-full pl-10 pr-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                                            id="email"
                                            name="email"
                                            placeholder="Enter your email"
                                            type="email"
                                            required
                                            value={email}
                                            onChange={(e) => setEmail(e.target.value)}
                                        />
                                    </div>
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1" htmlFor="password">Password</label>
                                    <div className="relative">
                                        <Lock className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 h-5 w-5" />
                                        <input
                                            className="w-full pl-10 pr-12 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                                            id="password"
                                            name="password"
                                            placeholder="Enter your password"
                                            type={showPassword ? 'text' : 'password'}
                                            required
                                            value={password}
                                            onChange={(e) => setPassword(e.target.value)}
                                        />
                                        <button
                                            type="button"
                                            onClick={() => setShowPassword(!showPassword)}
                                            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
                                        >
                                            {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                                        </button>
                                    </div>
                                </div>

                                {error && (
                                    <div className="text-sm text-red-500 bg-red-50 dark:bg-red-900/20 p-3 rounded-lg border border-red-200 dark:border-red-800">
                                        {error}
                                    </div>
                                )}

                                <div className="flex items-center justify-between">
                                    <label className="flex items-center cursor-pointer">
                                        <input className="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary dark:bg-gray-700 dark:border-gray-600" type="checkbox" />
                                        <span className="ml-2 text-sm text-gray-500 dark:text-gray-400">Remember Me</span>
                                    </label>
                                    <a className="text-sm font-medium text-primary hover:text-blue-700 transition-colors" href="#">Forgot Your Password?</a>
                                </div>

                                <button
                                    type="submit"
                                    disabled={loading}
                                    className="w-full bg-primary hover:bg-blue-600 text-white font-semibold py-3 px-4 rounded-lg shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-0.5 flex justify-center items-center gap-2"
                                >
                                    {loading ? <Loader2 className="h-5 w-5 animate-spin" /> : 'Log In'}
                                </button>

                                <div className="relative py-4">
                                    <div className="absolute inset-0 flex items-center">
                                        <div className="w-full border-t border-gray-200 dark:border-gray-700"></div>
                                    </div>
                                    <div className="relative flex justify-center text-sm">
                                        <span className="px-2 bg-white dark:bg-surface-dark text-gray-500">Or Login With</span>
                                    </div>
                                </div>

                                <div className="grid grid-cols-2 gap-4">
                                    <button
                                        type="button"
                                        className="flex items-center justify-center gap-2 px-4 py-2.5 border border-gray-200 dark:border-gray-700 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors bg-white dark:bg-gray-800"
                                    >
                                        <Chrome className="h-5 w-5 text-gray-600" />
                                        <span className="text-sm font-medium text-gray-700 dark:text-gray-200">Google</span>
                                    </button>
                                    <button
                                        type="button"
                                        className="flex items-center justify-center gap-2 px-4 py-2.5 border border-gray-200 dark:border-gray-700 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors bg-white dark:bg-gray-800"
                                    >
                                        <Apple className="h-5 w-5 text-gray-900 dark:text-white" />
                                        <span className="text-sm font-medium text-gray-700 dark:text-gray-200">Apple</span>
                                    </button>
                                </div>

                                <p className="text-center text-sm text-gray-600 dark:text-gray-400 mt-6">
                                    Don't Have An Account? <a className="text-primary font-semibold hover:underline" href="#">Register Now.</a>
                                </p>
                            </form>
                        </div>
                    </div>

                    <div className="mt-8 flex justify-between items-center text-xs text-gray-400">
                        <span>Copyright © 2026 ClinicBooking Systems LTD.</span>
                        <a className="hover:text-gray-600 dark:hover:text-gray-300" href="#">Privacy Policy</a>
                    </div>
                </div>

                {/* Right Side: Marketing Panel */}
                <div className="hidden lg:flex w-1/2 bg-primary relative overflow-hidden flex-col p-12 justify-center items-center">
                    <div className="absolute top-0 right-0 w-96 h-96 bg-white opacity-5 rounded-full blur-3xl transform translate-x-1/2 -translate-y-1/2"></div>
                    <div className="absolute bottom-0 left-0 w-80 h-80 bg-blue-400 opacity-20 rounded-full blur-3xl transform -translate-x-1/3 translate-y-1/3"></div>

                    <div className="relative z-10 w-full max-w-lg mb-12 text-center lg:text-left">
                        <h2 className="text-4xl xl:text-5xl font-bold text-white mb-6 leading-tight">
                            Effortlessly manage your clinic and staff.
                        </h2>
                        <p className="text-blue-100 text-lg opacity-90">
                            The most advanced healthcare administration platform for modern clinics.
                        </p>
                    </div>

                    {/* Stats Card Mockup */}
                    <div className="relative z-10 w-full max-w-xl">
                        <div className="bg-white rounded-2xl p-6 shadow-2xl transform transition-transform hover:scale-[1.02] duration-500">
                            <div className="flex justify-between items-start mb-6">
                                <div>
                                    <div className="h-4 w-32 bg-gray-200 rounded mb-2 font-bold text-gray-700">Platform Growth</div>
                                    <div className="h-3 w-48 bg-gray-100 rounded text-xs text-gray-400">Last 30 days overview</div>
                                </div>
                                <div className="flex gap-2">
                                    <div className="w-20 h-8 bg-gray-100 rounded-lg flex items-center justify-center text-xs text-gray-500">Monthly</div>
                                </div>
                            </div>

                            <div className="grid grid-cols-12 gap-4 mb-6">
                                <div className="col-span-4 bg-primary rounded-xl p-4 text-white flex flex-col justify-between h-32 relative overflow-hidden">
                                    <div className="absolute -right-4 -top-4 w-20 h-20 bg-white opacity-10 rounded-full"></div>
                                    <div>
                                        <p className="text-xs text-blue-200 mb-1">New Doctors</p>
                                        <p className="text-2xl font-bold">124</p>
                                    </div>
                                    <div className="flex items-center text-xs bg-white/20 w-fit px-2 py-1 rounded">
                                        <span>↑ 12%</span>
                                    </div>
                                </div>
                                <div className="col-span-4 bg-gray-50 rounded-xl p-4 flex flex-col justify-between h-32 border border-gray-100">
                                    <div>
                                        <p className="text-xs text-gray-500 mb-1">Average Response</p>
                                        <p className="text-xl font-bold text-gray-800">00:02:15</p>
                                    </div>
                                    <div className="h-8 w-full flex items-end gap-1">
                                        <div className="w-1/5 h-[40%] bg-blue-200 rounded-t"></div>
                                        <div className="w-1/5 h-[70%] bg-blue-300 rounded-t"></div>
                                        <div className="w-1/5 h-[50%] bg-blue-200 rounded-t"></div>
                                        <div className="w-1/5 h-[80%] bg-blue-400 rounded-t"></div>
                                        <div className="w-1/5 h-[60%] bg-blue-300 rounded-t"></div>
                                    </div>
                                </div>
                                <div className="col-span-4 bg-white rounded-xl p-4 border border-gray-100 shadow-sm flex flex-col h-32 relative">
                                    <p className="text-xs text-gray-500 mb-2">Verified Rate</p>
                                    <div className="flex-1 flex items-center justify-center relative">
                                        <div className="w-16 h-8 overflow-hidden relative">
                                            <div className="absolute w-16 h-16 rounded-full border-[8px] border-primary border-b-transparent border-l-transparent transform -rotate-45"></div>
                                        </div>
                                        <div className="absolute top-1/2 mt-1 text-center">
                                            <span className="block text-xs font-bold text-gray-800">92%</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div className="border border-gray-100 rounded-xl overflow-hidden">
                                <div className="bg-gray-50 px-4 py-2 border-b border-gray-100 flex justify-between">
                                    <div className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Recent Registrations</div>
                                    <ChevronRight className="h-3 w-3 text-gray-300" />
                                </div>
                                <div className="p-2 space-y-2">
                                    {[
                                        { name: 'Dr. Sarah Smith', time: '2m ago', status: 'bg-green-400' },
                                        { name: 'Dr. James Wilson', time: '15m ago', status: 'bg-blue-400' },
                                        { name: 'Dr. Elena Rodriguez', time: '1h ago', status: 'bg-yellow-400' }
                                    ].map((doc, i) => (
                                        <div key={i} className="flex items-center justify-between p-2 hover:bg-gray-50 rounded transition-colors group">
                                            <div className="flex items-center gap-3">
                                                <div className={`w-2 h-2 rounded-full ${doc.status}`}></div>
                                                <div className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center overflow-hidden">
                                                    <div className="w-full h-full bg-blue-50 text-[10px] flex items-center justify-center text-blue-600 font-bold">
                                                        {doc.name.split(' ').map(n => n[0]).join('')}
                                                    </div>
                                                </div>
                                                <div>
                                                    <div className="text-[11px] font-bold text-gray-800 group-hover:text-primary transition-colors">{doc.name}</div>
                                                    <div className="text-[9px] text-gray-400">Cardiology Specialist</div>
                                                </div>
                                            </div>
                                            <div className="text-[10px] text-gray-300 font-medium">{doc.time}</div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>
                        <div className="absolute -z-10 -bottom-6 -right-6 w-full h-full border-2 border-white/20 rounded-2xl"></div>
                    </div>
                </div>
            </div>
        </div>
    )
}
